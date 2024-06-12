extends WorkspaceArea
class_name Preview2DWorkspaceArea

func _init()->void:
	name = "Preview2DWorkspaceArea"
	mouse_entered.connect(_mouse_entered_2DPreview)
	mouse_exited.connect(_mouse_exited_2DPreview)

func _ready()->void:
	setupWorkspaceArea()

func _mouse_entered_2DPreview()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited_2DPreview()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
