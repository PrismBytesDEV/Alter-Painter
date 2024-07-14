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
func _init(Visible : bool, Colors : Array[Color], Name : String,Opacity : float, Type : int)->void:
	self.visible = Visible
	if Colors.is_empty():
		Colors.append(Color.WHITE)#Albedo
		Colors.append(Color(0.5,0.5,0.5))#Roughness
		Colors.append(Color(0.5,0.5,0.5))#Metalness
		Colors.append(Color("#8080ff"))#NormalMap (linear)
	self.colors = Colors
	self.name = Name
	self.opacity = Opacity
	self.type = Type

##tells is the layer currently hidden or not.
var visible : bool
##Holds all the colors for each individual channel that layer works on. See [enum ServerLayersStack.layerChannels]
## to read the list of available channels that layer can work on.
var colors : Array[Color] #<- The reason why I used array of colors instead of just one color
						  # Is the fact that a single layer can contribute to Albedo, Normal,
						  # Metallness, Roughness and etc at the same time
#var mask : Mask #<- requires a special class to handle mask calculations
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
