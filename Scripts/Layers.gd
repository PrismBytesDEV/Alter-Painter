extends Tree
class_name Layers

func _ready() -> void:
	var root := create_item()
	root.set_icon(0,preload("res://icon.png"))
	root.set_icon_max_width(0,20)
	var child1 = create_item(root)
	var child2 = create_item(root)
	var subchild1 = create_item(child1)
	subchild1.set_text(0, "Subchild1")

func _process(delta : float)-> void:
	pass
