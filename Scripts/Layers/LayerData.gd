class_name LayerData extends Resource

##This class holds all the data of a single fill layer inside the stack.
##This layer only stores color instead of a texture. For that use [PaintLayerData] instead.

##This is the contructor of this class.[br]
##So if you want to create completly new FillLayer you need to pass:[br]
##[param Visible] - should the created layer be visible or not?[br]
##[param Colors] - the color data for each individual material texture 
## See [enum ServerLayersStack.layerChannels]
## to read the list of available channels that layer can work on.[br]
##[param Name] - the name or title of the layer[br]
##[param Opacity] - define how transparent this layer should be when being created.[br]
##[param mixType] - type of the layer mix mode. See [member Mixer.mixTypes]
##to read list of all available mix modes
func _init(Visible : bool, Colors : Dictionary, Name : String,Opacity : float, MixType : int,LayerType : LayerData.layerTypes)->void:
	self.visible = Visible
	
	@warning_ignore("unassigned_variable")
	var fillDict : Dictionary = {
		ServerLayersStack.layerChannels.Albedo : Color.WHITE,
		ServerLayersStack.layerChannels.Roughness : 0.5,
		ServerLayersStack.layerChannels.Metalness : 0.0,
		ServerLayersStack.layerChannels.Normal : Color("#8080ff")
	}
	
	var textureRes := AlterProjectSettings.textureResolution
	
	var albedoImage := Image.create(textureRes.x,textureRes.y,false,Image.FORMAT_RGBA8)
	albedoImage.fill(Color.WHITE)
	var albedoTexture := ImageTexture.create_from_image(albedoImage)
	
	var rougnessImage := Image.create(textureRes.x,textureRes.y,false,Image.FORMAT_RGBA8)
	rougnessImage.fill(Color(0.5,0.5,0.5,1.0))
	var rougnessTexture := ImageTexture.create_from_image(rougnessImage)
	
	var metalnessImage := Image.create(textureRes.x,textureRes.y,false,Image.FORMAT_RGBA8)
	metalnessImage.fill(Color(0.5,0.5,0.5,1.0))
	var metalnessTexture := ImageTexture.create_from_image(metalnessImage)
	
	var normalImage := Image.create(textureRes.x,textureRes.y,false,Image.FORMAT_RGBA8)
	normalImage.fill(Color("#8080ff"))
	var normalTexture := ImageTexture.create_from_image(normalImage)
	
	@warning_ignore("unassigned_variable")
	var paintDict : Dictionary = {
		ServerLayersStack.layerChannels.Albedo : albedoTexture,
		ServerLayersStack.layerChannels.Roughness : rougnessTexture,
		ServerLayersStack.layerChannels.Metalness : metalnessTexture,
		ServerLayersStack.layerChannels.Normal : normalTexture
	}
	
	if Colors.has(ServerLayersStack.layerChannels.Albedo):
		match LayerType:
			LayerData.layerTypes.fill:
				fillDict[ServerLayersStack.layerChannels.Albedo] = Colors[ServerLayersStack.layerChannels.Albedo]
			LayerData.layerTypes.paint:
				print("albed text")
				paintDict[ServerLayersStack.layerChannels.Albedo] = Colors[ServerLayersStack.layerChannels.Albedo]
	if Colors.has(ServerLayersStack.layerChannels.Roughness):
		match LayerType:
			LayerData.layerTypes.fill:
				fillDict[ServerLayersStack.layerChannels.Roughness] = Colors[ServerLayersStack.layerChannels.Roughness]
			LayerData.layerTypes.paint:
				paintDict[ServerLayersStack.layerChannels.Roughness] = Colors[ServerLayersStack.layerChannels.Roughness]
	if Colors.has(ServerLayersStack.layerChannels.Metalness):
		match LayerType:
			LayerData.layerTypes.fill:
				fillDict[ServerLayersStack.layerChannels.Metalness] = Colors[ServerLayersStack.layerChannels.Metalness]
			LayerData.layerTypes.paint:
				paintDict[ServerLayersStack.layerChannels.Metalness] = Colors[ServerLayersStack.layerChannels.Metalness]
	if Colors.has(ServerLayersStack.layerChannels.Normal):
		match LayerType:
			LayerData.layerTypes.fill:
				fillDict[ServerLayersStack.layerChannels.Normal] = Colors[ServerLayersStack.layerChannels.Normal]
			LayerData.layerTypes.paint:
				paintDict[ServerLayersStack.layerChannels.Normal] = Colors[ServerLayersStack.layerChannels.Normal]
	
	match LayerType:
		LayerData.layerTypes.fill:
			self.colors = fillDict
		LayerData.layerTypes.paint:
			self.colors = paintDict
	self.name = Name
	self.opacity = Opacity
	self.mixType = MixType
	self.layerType = LayerType

##tells is the layer currently hidden or not.
var visible : bool
##Holds all the colors for each individual channel that layer works on. See [enum ServerLayersStack.layerChannels]
## to read the list of available channels that layer can work on.
var colors : Dictionary
##stores the name or title, of the layer.
var name : String
##store how transparent the layer is
##1 == full visible[br]
##0.5 = half visible[br]
##0 = invisible[br]
var opacity : float
##stores mix type of the layer. See [member Mixer.mixTypes]
##to read list of all available mix modes
var mixType : int

##List of all available options for a UI layer
enum layerTypes {
	##Layer uses Color or value as a property.
	fill,
	##Layer uses texture as a property
	paint
} 
##Type of the layer. In other word is this layer a fill layer, paint layer or is it an other type of layer
var layerType : layerTypes = layerTypes.fill
