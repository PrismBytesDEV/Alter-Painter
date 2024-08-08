class_name ServerBrushSettings extends RefCounted

##This class is used to store different brush settings (profiles) and manage them globally.



##Stores all brush profiles
static var allBrushesProfiles : Array[BrushProfile] = [
	_getDefaultBrushProfile()
]

##Hold reference to properties of currently used brush
static var currentBrushProfile : BrushProfile = allBrushesProfiles[0]

static func _getDefaultBrushProfile()->BrushProfile:
	var brushProf := BrushProfile.new()
	brushProf.brushColor = Color.BLACK
	brushProf.brushSize = 10.0
	brushProf.brushOpacity = 1.0
	return brushProf
