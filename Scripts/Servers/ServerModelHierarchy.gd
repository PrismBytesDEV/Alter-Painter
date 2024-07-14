class_name ServerModelHierarchy extends RefCounted

##This class stores informations about currently selected resource in the
## [ModelHierarchyWorkspaceArea] and allows to sync it across all those workspaces

static var _displays : Array[ModelHierarchyWorkspaceArea]

##Theme like setting, defines which color should be used on selected material
##It makes easier for a user to tell which material is currently edited by [LayersWorkspaceArea]
static var selectedMatThemeColor := Color("0096fc")
##This is the index of currently selected material.
##use it with [member Alter3DScene.modelMaterials] to get the currently selected material
static var selectedMaterialIndex : int

#DO NOT REMOVE or else ModelHierarchyWorkspaceArea
#won't work. I tried using set_meta("id") and then only
#using selectedMaterialIndex : int but it won't work
#If someone will make it work without using this variable
#Then I would be grateful if that person would make a pull request to fix this
##Stores the resource_name of the currently selectedMaterial
static var selectedMaterialName : String

#used to register new workspace so it can be modified by the server
#with static functions
static func _addDisplayWorkspaceArea(display : ModelHierarchyWorkspaceArea)->void:
	_displays.append(display)

#used to unregister workspace that is about to be removed or switched
static func _removeDisplayWorkspaceArea(display : ModelHierarchyWorkspaceArea)->void:
	var index := _displays.find(display)
	_displays.remove_at(index)

##Refreshes all the display data, which it restructures entire [Tree] in all registered
##[ModelHierarchyWorkspaceArea]s
static func refreshDisplayData()->void:
	for display in _displays:
		display.refreshDisplay()

##Refreshes all the text colors of material items in all registered
##[ModelHierarchyWorkspaceArea]s
static func refreshSelectedMaterialItems()->void:
	for display in _displays:
		display.changeItemTreeColors_init()
