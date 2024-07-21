class_name FillLayerData extends Resource

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
##[param Type] - type of the layer mix mode. See [member Mixer.mixTypes]
##to read list of all available mix modes
func _init(Visible : bool, Colors : Dictionary, Name : String,Opacity : float, Type : int)->void:
	self.visible = Visible
	
	@warning_ignore("unassigned_variable")
	var colorsDict : Dictionary = {
		ServerLayersStack.layerChannels.Albedo : Color.WHITE,
		ServerLayersStack.layerChannels.Roughness : 0.5,
		ServerLayersStack.layerChannels.Metalness : 0.0,
		ServerLayersStack.layerChannels.Normal : Color("#8080ff")
	}
	
	if Colors.has(ServerLayersStack.layerChannels.Albedo):
		colorsDict[ServerLayersStack.layerChannels.Albedo] = Colors[ServerLayersStack.layerChannels.Albedo]
	if Colors.has(ServerLayersStack.layerChannels.Roughness):
		colorsDict[ServerLayersStack.layerChannels.Roughness] = Colors[ServerLayersStack.layerChannels.Roughness]
	if Colors.has(ServerLayersStack.layerChannels.Metalness):
		colorsDict[ServerLayersStack.layerChannels.Metalness] = Colors[ServerLayersStack.layerChannels.Metalness]
	if Colors.has(ServerLayersStack.layerChannels.Normal):
		colorsDict[ServerLayersStack.layerChannels.Normal] = Colors[ServerLayersStack.layerChannels.Normal]
	
	self.colors = colorsDict
	self.name = Name
	self.opacity = Opacity
	self.type = Type

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
var type : int
