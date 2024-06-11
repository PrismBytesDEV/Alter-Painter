extends WorkspaceArea
class_name LayersWorkspaceArea

func _init()->void:
	name = "LayersWorkspaceArea"
	mouse_entered.connect(_mouse_entered_LayersArea)
	mouse_exited.connect(_mouse_exited_LayersArea)

func _ready()->void:
	setupWorkspaceArea()

func _mouse_entered_LayersArea()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited_LayersArea()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
