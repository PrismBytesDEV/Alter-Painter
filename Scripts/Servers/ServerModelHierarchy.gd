class_name ServerModelHierarchy extends RefCounted

static var _displays : Array[ModelHierarchyWorkspaceArea]

static var selectedMatThemeColor := Color("0096fc")
static var selectedMaterialIndex : int

#DO NOT REMOVE or else ModelHierarchyWorkspaceArea
#won't work. I tried using set_meta("id") and then only
#using selectedMaterialIndex : int but it won't work
#If someone will make it work without using this variable
#Then I would be grateful if that person would make a pull request to fix this
static var selectedMaterialName : String

static func addDisplayWorkspaceArea(display : ModelHierarchyWorkspaceArea)->void:
	_displays.append(display)

static func removeDisplayWorkspaceArea(display : ModelHierarchyWorkspaceArea)->void:
	var index := _displays.find(display)
	_displays.remove_at(index)

static func refreshDisplayData()->void:
	for display in _displays:
		display.refreshDisplay()

static func refreshSelectedMaterialItems()->void:
	for display in _displays:
		display.changeItemTreeColors_init()
