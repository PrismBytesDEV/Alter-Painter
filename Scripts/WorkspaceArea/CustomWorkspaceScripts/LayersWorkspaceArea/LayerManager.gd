extends VBoxContainer

var fillLayerUI : PackedScene = preload("res://Scenes/layer_ui_fill.tscn") 
@onready var layersList : ReorderableContainer = $"list scroll/List"

func add_new_fill_layer()->void:
	var newLayer := fillLayerUI.instantiate()
	layersList.add_child(newLayer)
	layersList.move_child(newLayer,0)
