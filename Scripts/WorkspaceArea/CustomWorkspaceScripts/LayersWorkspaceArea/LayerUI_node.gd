class_name LayerUI_node extends Button

signal layerSelected(layer : LayerUI_node)

@onready var ghostLayerScene : PackedScene = preload("res://Scenes/layer_ghost_fill.tscn")
var layersWorkspaceParent : LayersWorkspaceArea
var createdGhost : GhostFillLayer
var layerData : FillLayerData

@onready var visibilityButton : CheckBox = %VisibilityButton
@onready var fillColorButton : ColorPickerButton = %FillColorPicker
@onready var layerNameEdit : LineEdit = %LayerName
@onready var opacitySlider : HSlider = %OpacitySlider
@onready var typeSwitchButton : OptionButton = %LayerType

func _ready()->void:
	pressed.connect(_layerSelected)
	visibilityButton.button_pressed = layerData.visible
	fillColorButton.color = layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode]
	layerNameEdit.text = layerData.name
	opacitySlider.value = layerData.opacity * opacitySlider.max_value
	typeSwitchButton.selected = layerData.type

func _layerSelected()->void:
	layerSelected.emit(self)

func _visibilityChanged(state : bool)->void:
	layerData.visible = state
	ServerLayersStack.syncLayerProperties(get_index(),self)

func _colorChanged(newColor : Color)->void:
	layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode] = newColor
	ServerLayersStack.syncLayerProperties(get_index(),self)

func _titleChanged(newTitle : String)->void:
	layerData.name = newTitle
	ServerLayersStack.syncLayerProperties(get_index(),self)

func _opacityChanged(sliderValue : float)->void:
	layerData.opacity = sliderValue / opacitySlider.max_value
	ServerLayersStack.syncLayerProperties(get_index(),self)

func _typeChanged(index : int)->void:
	layerData.type = index
	ServerLayersStack.syncLayerProperties(get_index(),self)

func _get_drag_data(_at_position : Vector2)->Variant:
	#Called when layer started to be dragged by cursor
	createdGhost = ghostLayerScene.instantiate()
	get_tree().root.add_child(createdGhost)
	_copySize(self,createdGhost)
	LayersWorkspaceArea.draggingAnyLayer = true
	return self

func updatePropertiesFromData()->void:
	self.visibilityButton.button_pressed = layerData.visible
	self.fillColorButton.color = layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode]
	self.layerNameEdit.text = layerData.name
	self.opacitySlider.value = layerData.opacity * opacitySlider.max_value
	self.typeSwitchButton.selected = layerData.type

#Used to set size instead of to.size = from.size
#Because this makes Godot yell with warnings to use anchors instead ;d
func _copySize(from : Control, to : Control)->void:
	to.set_anchor_and_offset(SIDE_LEFT,from.anchor_left,from.offset_left)
	to.set_anchor_and_offset(SIDE_TOP,from.anchor_top,from.offset_top)
	to.set_anchor_and_offset(SIDE_RIGHT,from.anchor_right,from.offset_right)
	to.set_anchor_and_offset(SIDE_BOTTOM,from.anchor_bottom,from.offset_bottom)
