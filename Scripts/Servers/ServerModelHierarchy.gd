extends RefCounted
class_name ServerModelHierarchy

static var _displays : Array[ModelHierarchyWorkspaceArea]

static var selectedMatThemeColor := Color("0096fc")
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
