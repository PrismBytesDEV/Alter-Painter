extends Control
class_name WorkspaceArea

#Contains the workspace that mouse is currently hovering over
static var CurrentMouseHoverArea : WorkspaceArea

#Made for debug purposes to show active workspaces tha mouse is hovering over
static var debugCurrentHoverArea : bool = false

func _ready()-> void:
	#debugCurrentHoverArea = true
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func _mouse_entered()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
