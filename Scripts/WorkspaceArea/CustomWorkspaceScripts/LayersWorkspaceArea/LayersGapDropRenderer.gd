extends Control
class_name LayersGapRenderer

var selfWorkspaceArea : LayersWorkspaceArea
var layerSize : Vector2

@onready var listScroll : ScrollContainer = %listScroll

func _draw()->void:
	if WorkspaceArea.CurrentMouseHoverArea != selfWorkspaceArea:
		#Used to make sure that there is only one gap line rendered
		#When mouse hovered from one LayersWorkspaceArea to another
		return
	if !LayersWorkspaceArea.draggingAnyLayer:
		return
	if !LayersWorkspaceArea.canDropLayer:
		return
	
	var mousePos : Vector2 = get_viewport().get_mouse_position() - self.global_position
	var gapPos : Vector2 = Vector2.ZERO
	var layerSpacing : float = layerSize.y + get_theme_constant("separation")
	@warning_ignore("narrowing_conversion")
	var gapYMod : int = (mousePos.y + (0.5 * layerSpacing)) / layerSpacing
	gapYMod = min(gapYMod * layerSpacing,get_child_count() * layerSpacing)
	gapPos.y = gapYMod
	#draw_line(Vector2(0,mousePos.y),Vector2(0,mousePos.y) + Vector2.RIGHT * self.size.x,Color.GREEN,3.0)
	draw_line(gapPos,gapPos + Vector2.RIGHT * self.size.x,Color("0096fc"),3.0)