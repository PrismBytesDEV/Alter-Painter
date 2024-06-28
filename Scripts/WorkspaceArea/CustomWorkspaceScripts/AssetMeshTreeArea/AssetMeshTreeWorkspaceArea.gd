extends WorkspaceArea
class_name AssetMeshTreeWorkspaceArea

func _init():
	name = "AssetMeshTreeArea"
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func _ready():
	setupWorkspaceArea()

func _mouse_entered()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
