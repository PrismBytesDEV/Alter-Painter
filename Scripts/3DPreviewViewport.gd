extends SubViewport

func _ready():
	pass
	#var node_3d : Node = $Node3D
	#var renderModePickButton : OptionButton = node_3d.find_child("Control").find_child("RenderModePickButton")
	#renderModePickButton.item_selected.connect(selectRenderMode)


func selectRenderMode(mode : int)-> void:
	renderingMode = mode

var renderingMode : int :
	set(value):
		renderingMode = value
		match(value):
			0:#Default
				debug_draw = Viewport.DEBUG_DRAW_DISABLED
			1:#Albedo
				debug_draw = Viewport.DEBUG_DRAW_UNSHADED
			2:#NormalMap
				debug_draw = Viewport.DEBUG_DRAW_NORMAL_BUFFER
			3:#Roughness
				debug_draw = Viewport.DEBUG_DRAW_UNSHADED
			4:#Metalness
				debug_draw = Viewport.DEBUG_DRAW_UNSHADED
			4:#Heightmap
				debug_draw = Viewport.DEBUG_DRAW_UNSHADED
