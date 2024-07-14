class_name Preview3DViewport extends SubViewport

##This class should allow to switch between different render preview modes
## like for example switching viewport to DEBUG_DRAW_UNSHADED to show only surface's color
## But this solution is very limited and probably will require reworking.

func _selectRenderMode(mode : int)-> void:
	renderingMode = mode

##Defines current preview render mode.
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
