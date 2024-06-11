extends WorkspaceArea
class_name Preview3DWorkspaceArea

var workspaceCameraController : cameraController 
var renderModePickButton : OptionButton
var renderViewport : Preview3DViewport

func _init()->void:
	name = "Preview3DWorkspaceArea"
	mouse_entered.connect(_mouse_entered_3DPreview)
	mouse_exited.connect(_mouse_exited_3DPreview)

func _ready() -> void:
	setupWorkspaceArea()
	
	renderViewport = areaContent.get_child(0)
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
	renderModePickButton.item_selected.connect(renderViewport.selectRenderMode)
	
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
