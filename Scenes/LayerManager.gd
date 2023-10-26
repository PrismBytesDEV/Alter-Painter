extends VBoxContainer

var fillLayerUI = preload("res://Scenes/layer_ui_fill.tscn") 
@onready var layersList : ReorderableContainer = $"list scroll/List"

func _ready():
	var d := Texture2D.new()

func add_new_fill_layer():
	var newLayer := fillLayerUI.instantiate()
	layersList.add_child(newLayer)
	layersList.move_child(newLayer,0)
