extends Resource
class_name FillLayerData

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

var visible : bool
var colors : Array[Color] #<- The reason why I used array of colors instead of just one color
						  # Is the fact that a single layer can contribute to Albedo, Normal,
						  # Metallness, Roughness and etc at the same time
#var mask : Mask #<- requires a special class to handle mask calculations
var name : String
var opacity : float
var type : int
