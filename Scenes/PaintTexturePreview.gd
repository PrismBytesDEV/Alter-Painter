@tool
class_name PaintTexturePreview extends Control

const _margin : int = 3

@export var texture : Texture2D

func _ready()->void:
	pass

func _process(_delta:float)->void:
	queue_redraw()

func _draw()->void:
	if texture == null:
		return
	var rect := Rect2(_margin,_margin,size.x - 2 * _margin,size.y - 2 * _margin)
	draw_texture_rect(texture,rect,false)
