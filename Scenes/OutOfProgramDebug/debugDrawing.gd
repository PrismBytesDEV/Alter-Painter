extends TextureRect

var mousePos : Vector2
var prevMousePos : Vector2

func _ready()->void:
	texture = painter.texture

func _brushSizeChanged(value : float)->void:
	painter.brushSize = Vector2(value,value)
	#RenderingServer.call_on_render_thread(_computeUpdate.bind(resolution,mousePos,brushSize,brushColor))

func _brushColorChanged(color : Color)->void:
	painter.brushColor = color
	#RenderingServer.call_on_render_thread(_computeUpdate.bind(resolution,mousePos,brushSize,brushColor))

func _input(_event : InputEvent)->void:
	mousePos = get_local_mouse_position()
	mousePos.x /= size.x
	mousePos.y /= size.y
	if Input.is_action_pressed("paint"):
		if mousePos == mousePos.clamp(Vector2.ZERO,Vector2.ONE):
			painter.paint(mousePos)
			prevMousePos = mousePos
