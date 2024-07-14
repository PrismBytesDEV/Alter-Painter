class_name Preview3DWorkspaceArea extends WorkspaceArea

##This [WorkspaceArea] is used to preview 3D scene and allows move around the imported 3D model.

##This is the camera controller that have the functionality to move around the scene.
var workspaceCameraController : cameraController 
##This is reference to the button that allow user to switch between different render preview modes.
var renderModePickButton : OptionButton
##This is reference to the viewport that includes the code to switch between different render preview modes.
var renderViewport : Preview3DViewport

func _init()->void:
	name = "Preview3DWorkspaceArea"
	mouse_entered.connect(_mouse_entered_3DPreview)
	mouse_exited.connect(_mouse_exited_3DPreview)

func _ready() -> void:
	setupWorkspaceArea()
	
	renderViewport = _areaContent.get_child(0)
	workspaceCameraController = renderViewport.get_child(0)
	
	renderModePickButton = OptionButton.new()
	renderModePickButton.size_flags_horizontal = SIZE_SHRINK_END + SIZE_EXPAND
	renderModePickButton.add_item("default")
	renderModePickButton.add_item("albedo")
	renderModePickButton.add_item("normal_map")
	renderModePickButton.add_item("roughness")
	renderModePickButton.add_item("metalness")
	renderModePickButton.add_item("heightmap")
	renderModePickButton.selected = 0
	areaOptionsContainer.add_child(renderModePickButton)
	renderModePickButton.item_selected.connect(renderViewport._selectRenderMode)
	
	var separator := Control.new()
	areaOptionsContainer.add_child(separator)
	separator.custom_minimum_size = Vector2i(8,0)

func _mouse_entered_3DPreview()->void:
	CurrentMouseHoverArea = self
	if workspaceCameraController != null:
		workspaceCameraController.process_mode = Node.PROCESS_MODE_INHERIT
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited_3DPreview()->void:
	CurrentMouseHoverArea = null
	if workspaceCameraController != null:
		workspaceCameraController.process_mode = Node.PROCESS_MODE_DISABLED
	if debugCurrentHoverArea:
		modulate = Color.WHITE
