class_name Preview2DWorkspaceArea extends WorkspaceArea

##This [WorkspaceArea] will be used to preview 2D textures and allow paint on them.[br]
## Although right now it does nothing... I'll need to work on it d:

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
