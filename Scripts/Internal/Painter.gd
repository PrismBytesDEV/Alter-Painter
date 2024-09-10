class_name Painter extends Node

var resolution : Vector2i = AlterProjectSettings.textureResolution

var albedoTexture : Texture2DRD
#OcclusionRougnessMetalnessTransparency
var ORMTexture : Texture2DRD
var normalTexture : Texture2DRD

var currentlyEditedLayerData : LayerData:
	set(newLayerData):
		if currentlyEditedLayerData != null:
			reloadTextureFromSelectedLayer(currentlyEditedLayerData,newLayerData)
			#RenderingServer.call_on_render_thread(reloadTextureFromSelectedLayer.bind(currentlyEditedLayerData,newLayerData)) 
		currentlyEditedLayerData = newLayerData

func _ready()->void:
	#var emptyImage := Image.create(resolution.x,resolution.y,false,Image.FORMAT_RGBA8)
	#emptyImage.fill(Color.TRANSPARENT)
	#albedoTexture = ImageTexture.create_from_image(emptyImage)
	albedoTexture = Texture2DRD.new()
	
	_computeInit(resolution)
	#RenderingServer.call_on_render_thread(_computeInit.bind(resolution))

func _exit_tree()->void:
	
	if albedoTexture:
		albedoTexture.texture_rd_rid = RID()
	
	_computeCleanup()
	#RenderingServer.call_on_render_thread(_computeCleanup) 

##Paints into the current albedoTexture with current brush's settings
## and at the specified [param UVPos]ition
func paint(UVPos : Vector2)->void:
	_computeUpdate(resolution,UVPos,ServerBrushSettings.currentBrushProfile)
	#RenderingServer.call_on_render_thread(_computeUpdate.bind(resolution,UVPos,ServerBrushSettings.currentBrushProfile))

func reloadTextureFromSelectedLayer(oldLayerData : LayerData,newLayerData : LayerData)->void:
	#print("old ",oldLayerData,"new ",newLayerData)
	if oldLayerData.layerType == LayerData.layerTypes.paint:
		var imgData : PackedByteArray = _RD.texture_get_data(_texture_rds[0],0)
		var textureSize : Vector2i = AlterProjectSettings.textureResolution
		var image := Image.create_from_data(textureSize.x,textureSize.y,false,Image.FORMAT_RGBA8,imgData)
		var convertedTexture := ImageTexture.create_from_image(image)
		
		oldLayerData.colors[0] = convertedTexture
		#if Preview3DWorkspaceArea.debugTextureRect != null:
			#Preview3DWorkspaceArea.debugTextureRect.albedoTexture = convertedTexture
	if newLayerData.layerType != LayerData.layerTypes.paint:
		return
	
	if newLayerData.layerType == LayerData.layerTypes.paint:
		var data : PackedByteArray = newLayerData.colors[0].get_image().get_data()
		_texture_rds[0] = _RD.texture_create(_textureFormat, RDTextureView.new(), [data])
		_texture_sets[0] = _create_uniform_set(_texture_rds[0])
		if albedoTexture:
			albedoTexture.texture_rd_rid = _texture_rds[0]
			#if Preview3DWorkspaceArea.debugTextureRect != null:
				#Preview3DWorkspaceArea.debugTextureRect.albedoTexture = albedoTexture

		
#region Compute shader Managment
var _RD : RenderingDevice
var _shader : RID
var _pipeline : RID

var _texture_rds : Array[RID] = [ RID(), RID()]
var _texture_sets : Array[RID] = [ RID(), RID()]

var _textureFormat : RDTextureFormat

func updateResolutionFormat(textureRes : Vector2i)->void:
	if _textureFormat == null:
		return
	_textureFormat.width = textureRes.x
	_textureFormat.height = textureRes.y

func _computeInit(res : Vector2i)->void:
	
	#_RD = RenderingServer.create_local_rendering_device()
	_RD = RenderingServer.get_rendering_device()
	
	var shader_file : RDShaderFile = load("res://Scripts/Internal/PainterCompute.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	_shader = _RD.shader_create_from_spirv(shader_spirv)
	_pipeline = _RD.compute_pipeline_create(_shader)
	
	_textureFormat = RDTextureFormat.new()
	_textureFormat.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	_textureFormat.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	_textureFormat.width = res.x
	_textureFormat.height = res.y
	_textureFormat.depth = 1
	_textureFormat.array_layers = 1
	_textureFormat.mipmaps = 1
	_textureFormat.usage_bits = (RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	 + RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT
	 + RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT)
	
	_texture_rds[0] = _RD.texture_create(_textureFormat, RDTextureView.new(), [])
	_texture_rds[1] = _RD.texture_create(_textureFormat, RDTextureView.new(), [])
	
	_RD.texture_clear(_texture_rds[0], Color.TRANSPARENT, 0, 1, 0, 1)
	_texture_sets[0] = _create_uniform_set(_texture_rds[0])
	
	if albedoTexture:
		albedoTexture.texture_rd_rid = _texture_rds[0]

func _computeUpdate(res : Vector2i,_mousePos : Vector2,_brushProfile : BrushProfile)->void:
	_RD.texture_clear(_texture_rds[1], Color.TRANSPARENT, 0, 1, 0, 1)
	_texture_sets[1] = _create_uniform_set(_texture_rds[1])
	
	var _brushColor : Color = _brushProfile.brushColor
	var _brushSize : Vector2 = Vector2.ONE * _brushProfile.brushSize
	
	var pushConstant := PackedByteArray()
	pushConstant.resize(48)
	#Setting "color" in brushParams
	pushConstant.encode_float(0,_brushColor.r)
	pushConstant.encode_float(4,_brushColor.g)
	pushConstant.encode_float(8,_brushColor.b)
	pushConstant.encode_float(12,_brushColor.a)
	#Setting "ORMT" in brushParams
	pushConstant.encode_float(16,_brushProfile.brushAO)
	pushConstant.encode_float(20,_brushProfile.brushRougness)
	pushConstant.encode_float(24,_brushProfile.brushMetalness)
	pushConstant.encode_float(28,_brushProfile.brushTransparency)
	#Setting "size" in brushParams
	pushConstant.encode_float(32,_brushSize.x)
	pushConstant.encode_float(36,_brushSize.y)
	#Setting "position" in brushParams
	var mousePosInImage : Vector2 = Vector2(res) * _mousePos 
	
	pushConstant.encode_float(40,mousePosInImage.x)
	pushConstant.encode_float(44,mousePosInImage.y)
	
	
	var compute_list := _RD.compute_list_begin()
	_RD.compute_list_bind_compute_pipeline(compute_list, _pipeline)
	_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[0], 0)
	_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[1], 1)
	_RD.compute_list_set_push_constant(compute_list, pushConstant, pushConstant.size())
	_RD.compute_list_dispatch(compute_list, (res.x) / 8, (res.y) / 8, 1)
	_RD.compute_list_end()
	
	#_RD.submit()
	#_RD.sync()
	
	mixer.mixInputs(ServerModelHierarchy.selectedMaterialIndex)

func _computeCleanup()->void:
	
	# Note that our sets and pipeline are cleaned up automatically as they are dependencies :P
	for textureRD in _texture_rds:
		_RD.free_rid(textureRD)

	if _shader:
		_RD.free_rid(_shader)

func _create_uniform_set(texture_rd : RID) -> RID:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = 0
	uniform.add_id(texture_rd)
	
	return _RD.uniform_set_create([uniform], _shader, 0)

#endregion
