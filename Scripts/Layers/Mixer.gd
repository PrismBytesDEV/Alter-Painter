class_name Mixer extends Node

##[Mixer] does the heavy lifting with combinig layers from the stack
##into result textures that are further automatically applied into materials

##List of all available mix operations
##that mixer can perform on texture with a layer
enum mixTypes
{
	Add,
	Subtract,
	Multiply
}

@export var textureResolution : Vector2i = Vector2i(512, 512)
@export var textureMask : Image
var debugImage : Image

var _outputAlbedoTexture : Texture2D

func _ready()->void:
	textureMask = load("res://textures/GodotDoodleMask.jpg").get_image()
	debugImage = load("res://textures/FaceWithAlpha.png").get_image()
	#Mixer is running all the preparations for compute shader on separate thread.
	#or at least it could that's why I used call_on_render_thread,
	#but Godot prevents program from crashing because of issue that I don't understand.
	#So currently I'll leave it as it is and let it work on single thread.
	#But if the issue will be resolved then this should allow Mixer to use multithreading.
	RenderingServer.call_on_render_thread(_computeInit.bind(textureResolution)) 

func _exit_tree()->void:
	RenderingServer.call_on_render_thread(_computeCleanup) 

##Running this method starts processing all the layers of the materiarial of [param matID]
## this id must be contained in boundries of [member Alter3DScene.modelMaterials].[br]
##And at the end it applies the changes into the material specified by the id
##This function is called every time when layer is added, removed or modified
func mixInputs(matID : int, recalculateMode : int = -1)->void:
	_outputAlbedoTexture = null
	
	var layersStack := ServerLayersStack.materialsLayers[matID].layers
	RenderingServer.call_on_render_thread(_computeUpdate.bind(layersStack,textureResolution,matID,recalculateMode)) 

#region Compute Shader Managment
var _RD : RenderingDevice
var _shader : RID
var _pipeline : RID

var _texture_rds : Array[RID] = [ RID(), RID(), RID()]
var _texture_sets : Array[RID] = [ RID(), RID(), RID()]

var _textureFormat : RDTextureFormat
var _maskFormat : RDTextureFormat

var _debugFormat : RDTextureFormat

func _computeInit(textureSize : Vector2i)->void:
	
	_RD = RenderingServer.create_local_rendering_device()
	
	var shader_file : RDShaderFile = load("res://Scripts/Layers/MixerCompute.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	_shader = _RD.shader_create_from_spirv(shader_spirv)
	_pipeline = _RD.compute_pipeline_create(_shader)
	
	_textureFormat = RDTextureFormat.new()
	_textureFormat.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	_textureFormat.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	_textureFormat.width = textureSize.x
	_textureFormat.height = textureSize.y
	_textureFormat.depth = 1
	_textureFormat.array_layers = 1
	_textureFormat.mipmaps = 1
	_textureFormat.usage_bits = (RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	 + RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT
	 + RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT)
	
	_maskFormat = RDTextureFormat.new()
	_maskFormat.format = RenderingDevice.DATA_FORMAT_R8_UNORM
	_maskFormat.texture_type = RenderingDevice.TEXTURE_TYPE_2D
	_maskFormat.width = textureSize.x
	_maskFormat.height = textureSize.y
	_maskFormat.depth = 1
	_maskFormat.array_layers = 1
	_maskFormat.mipmaps = 1
	_maskFormat.usage_bits = (RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	 + RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT
	 + RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT)
	
	_debugFormat = RDTextureFormat.new()
	_debugFormat.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	_debugFormat.width = debugImage.get_width()
	_debugFormat.height = debugImage.get_height()
	_debugFormat.usage_bits = (RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	 + RenderingDevice.TEXTURE_USAGE_COLOR_ATTACHMENT_BIT
	 + RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT
	 + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT)

func _computeUpdate(layersStack : Array[FillLayerData],textureSize : Vector2i,matID : int,recalculateMode : int = -1)->void:
	
	var material := Alter3DScene.modelMaterials[matID]
	if recalculateMode == ServerLayersStack.layerChannels.Albedo or recalculateMode == -1:
		_texture_rds[0] = _RD.texture_create(_textureFormat, RDTextureView.new(), [])
		_RD.texture_clear(_texture_rds[0], Color.WHITE, 0, 1, 0, 1)
		_texture_sets[0] = _create_uniform_set(_texture_rds[0])
		for layerID : int in layersStack.size():
			var layer : FillLayerData = layersStack[layerID]
			if !layer.visible:
				continue
			
			_texture_rds[1] = _RD.texture_create(_debugFormat, RDTextureView.new(), [debugImage.get_data()])
			#_RD.texture_clear(_texture_rds[1], layer.colors[ServerLayersStack.layerChannels.Albedo], 0, 1, 0, 1)
			_texture_sets[1] = _create_uniform_set(_texture_rds[1])
			
			_texture_rds[2] = _RD.texture_create(_maskFormat, RDTextureView.new(), [])
			_RD.texture_clear(_texture_rds[2], Color(1, 1, 1, 1), 0, 1, 0, 1)
			_texture_sets[2] = _create_uniform_set(_texture_rds[2])
			
			var pushConstant := PackedByteArray()
			pushConstant.resize(16)
			#Setting "textureSize" in layerParams
			pushConstant.encode_float(0,textureSize.x)
			pushConstant.encode_float(4,textureSize.y)
			#Setting "mixMode" in layerParams
			pushConstant.encode_u32(8,layer.type)
			#Setting "opacity" in layerParams
			pushConstant.encode_float(12,layer.opacity)
			
			var compute_list := _RD.compute_list_begin()
			_RD.compute_list_bind_compute_pipeline(compute_list, _pipeline)
			_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[0], 0)
			_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[1], 1)
			_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[2], 2)
			_RD.compute_list_set_push_constant(compute_list, pushConstant, pushConstant.size())
			_RD.compute_list_dispatch(compute_list, (textureSize.x) / 8, (textureSize.y) / 8, 1)
			_RD.compute_list_end()
			
			_RD.submit()
			_RD.sync()
		
		var imageData : PackedByteArray = _RD.texture_get_data(_texture_rds[0],0)
		var image := Image.create_from_data(textureResolution.x,textureResolution.y,false,Image.FORMAT_RGBA8,imageData)
		var imgTexture := ImageTexture.create_from_image(image)
		if Preview3DWorkspaceArea.debugTextureRect != null:
			Preview3DWorkspaceArea.debugTextureRect.texture = imgTexture
		material.albedo_texture = imgTexture
	if recalculateMode == ServerLayersStack.layerChannels.Roughness or recalculateMode == -1:
		_texture_rds[0] = _RD.texture_create(_textureFormat, RDTextureView.new(), [])
		_RD.texture_clear(_texture_rds[0], Color(0.5,0.5,0.5,1.0), 0, 1, 0, 1)
		_texture_sets[0] = _create_uniform_set(_texture_rds[0])
		for layerID : int in layersStack.size():
			var layer : FillLayerData = layersStack[layerID]
			if !layer.visible:
				continue
			
			_texture_rds[1] = _RD.texture_create(_textureFormat, RDTextureView.new(), [])
			var rougnessColor : Color = Color.WHITE *  layer.colors[ServerLayersStack.layerChannels.Roughness]
			rougnessColor.a = 1.0
			_RD.texture_clear(_texture_rds[1], rougnessColor, 0, 1, 0, 1)
			_texture_sets[1] = _create_uniform_set(_texture_rds[1])
			
			_texture_rds[2] = _RD.texture_create(_maskFormat, RDTextureView.new(), [])
			_RD.texture_clear(_texture_rds[2], Color(1, 1, 1, 1), 0, 1, 0, 1)
			_texture_sets[2] = _create_uniform_set(_texture_rds[2])
			
			var pushConstant := PackedByteArray()
			pushConstant.resize(16)
			#Setting "textureSize" in layerParams
			pushConstant.encode_float(0,textureSize.x)
			pushConstant.encode_float(4,textureSize.y)
			#Setting "mixMode" in layerParams
			pushConstant.encode_u32(8,layer.type)
			#Setting "opacity" in layerParams
			pushConstant.encode_float(12,layer.opacity)
			
			var compute_list := _RD.compute_list_begin()
			_RD.compute_list_bind_compute_pipeline(compute_list, _pipeline)
			_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[0], 0)
			_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[1], 1)
			_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[2], 2)
			_RD.compute_list_set_push_constant(compute_list, pushConstant, pushConstant.size())
			_RD.compute_list_dispatch(compute_list, (textureSize.x) / 8, (textureSize.y) / 8, 1)
			_RD.compute_list_end()
			
			_RD.submit()
			_RD.sync()
		
		var imageData : PackedByteArray = _RD.texture_get_data(_texture_rds[0],0)
		var image := Image.create_from_data(textureResolution.x,textureResolution.y,false,Image.FORMAT_RGBA8,imageData)
		var imgTexture := ImageTexture.create_from_image(image)
		if Preview3DWorkspaceArea.debugTextureRect != null:
			Preview3DWorkspaceArea.debugTextureRect.texture = imgTexture
		material.roughness_texture = imgTexture
	if recalculateMode == ServerLayersStack.layerChannels.Metalness or recalculateMode == -1:
		_texture_rds[0] = _RD.texture_create(_textureFormat, RDTextureView.new(), [])
		_RD.texture_clear(_texture_rds[0], Color.BLACK, 0, 1, 0, 1)
		_texture_sets[0] = _create_uniform_set(_texture_rds[0])
		for layerID : int in layersStack.size():
			var layer : FillLayerData = layersStack[layerID]
			if !layer.visible:
				continue
			
			_texture_rds[1] = _RD.texture_create(_textureFormat, RDTextureView.new(), [])
			var metalnessColor : Color = Color.WHITE *  layer.colors[ServerLayersStack.layerChannels.Metalness]
			metalnessColor.a = 1.0
			_RD.texture_clear(_texture_rds[1], metalnessColor, 0, 1, 0, 1)
			_texture_sets[1] = _create_uniform_set(_texture_rds[1])
			
			_texture_rds[2] = _RD.texture_create(_maskFormat, RDTextureView.new(), [])
			_RD.texture_clear(_texture_rds[2], Color(1, 1, 1, 1), 0, 1, 0, 1)
			_texture_sets[2] = _create_uniform_set(_texture_rds[2])
			
			var pushConstant := PackedByteArray()
			pushConstant.resize(16)
			#Setting "textureSize" in layerParams
			pushConstant.encode_float(0,textureSize.x)
			pushConstant.encode_float(4,textureSize.y)
			#Setting "mixMode" in layerParams
			pushConstant.encode_u32(8,layer.type)
			#Setting "opacity" in layerParams
			pushConstant.encode_float(12,layer.opacity)
			
			var compute_list := _RD.compute_list_begin()
			_RD.compute_list_bind_compute_pipeline(compute_list, _pipeline)
			_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[0], 0)
			_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[1], 1)
			_RD.compute_list_bind_uniform_set(compute_list, _texture_sets[2], 2)
			_RD.compute_list_set_push_constant(compute_list, pushConstant, pushConstant.size())
			_RD.compute_list_dispatch(compute_list, (textureSize.x) / 8, (textureSize.y) / 8, 1)
			_RD.compute_list_end()
			
			_RD.submit()
			_RD.sync()
		
		var imageData : PackedByteArray = _RD.texture_get_data(_texture_rds[0],0)
		var image := Image.create_from_data(textureResolution.x,textureResolution.y,false,Image.FORMAT_RGBA8,imageData)
		var imgTexture := ImageTexture.create_from_image(image)
		if Preview3DWorkspaceArea.debugTextureRect != null:
			Preview3DWorkspaceArea.debugTextureRect.texture = imgTexture
		material.metallic_texture = imgTexture
	
	Alter3DScene.modelMaterials[matID] = material

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
	# Even though we're using 3 sets, they are identical, so we're kinda cheating.
	return _RD.uniform_set_create([uniform], _shader, 0)

#endregion
