class_name BrushSettingsWorkspaceArea extends WorkspaceArea

##This [WorkspaceArea] is used to edit brush input settings, like it's size, opacity, color etc.

func _init()->void:
	name = "BrushSettingsWorkspaceArea"
	mouse_entered.connect(_mouse_entered_debug_area)
	mouse_exited.connect(_mouse_exited_debug_area)

func _ready()->void:
	setupWorkspaceArea()

func _mouse_entered_debug_area()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited_debug_area()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
