extends WorkspaceArea
class_name Preview3DWorkspaceArea

var workspaceCameraController : cameraController 

func _init()->void:
	mouse_entered.connect(_mouse_entered_3DPreview)
	mouse_exited.connect(_mouse_exited_3DPreview)

func _ready() -> void:
	workspaceCameraController = %CameraController

func _mouse_entered_3DPreview()->void:
	CurrentMouseHoverArea = self
	workspaceCameraController.process_mode = Node.PROCESS_MODE_INHERIT
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited_3DPreview()->void:
	CurrentMouseHoverArea = null
	workspaceCameraController.process_mode = Node.PROCESS_MODE_DISABLED
	if debugCurrentHoverArea:
		modulate = Color.WHITE
