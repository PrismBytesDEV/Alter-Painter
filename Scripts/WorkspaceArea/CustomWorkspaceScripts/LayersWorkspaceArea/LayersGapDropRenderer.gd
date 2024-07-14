class_name LayersGapRenderer extends VBoxContainer

##This class is used to render the gap line where, dragged by the user, layer
## will be dropped.

var _selfWorkspaceArea : LayersWorkspaceArea
##This is the size of the first layer in the UI stack
## used for calculating offsets and position where gap should be rendered
var layerSize : Vector2

var _separation : float

func _ready()->void:
	_separation = get_theme_constant("separation")

func _draw()->void:
	if WorkspaceArea.CurrentMouseHoverArea != _selfWorkspaceArea:
		#Used to make sure that there is only one gap line rendered
		#When mouse hovered from one LayersWorkspaceArea to another
		return
	if !LayersWorkspaceArea.draggingAnyLayer:
		return
	if !LayersWorkspaceArea.canDropLayer:
		return
	
	var mousePos : Vector2 = get_viewport().get_mouse_position() - self.global_position
	var gapPos := Vector2.ZERO
	var layerSpacing : float = layerSize.y + _separation
	@warning_ignore("narrowing_conversion")
	var gapYMod : int = (mousePos.y + (0.5 * layerSpacing)) / layerSpacing
	gapYMod = min(gapYMod * layerSpacing,get_child_count() * layerSpacing)
	gapPos.y = gapYMod
	draw_line(gapPos,gapPos + Vector2.RIGHT * self.size.x,Color("0096fc"),3.0)
