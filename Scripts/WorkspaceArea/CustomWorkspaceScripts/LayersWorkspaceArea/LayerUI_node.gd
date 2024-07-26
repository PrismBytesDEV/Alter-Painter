class_name LayerUI_node extends Button

##This is the class that previews particular layer's data
## and allows to modify it by the user from UI.

##This signal is emmited when this layer is selected by the user in the UI[br]
##[param layer] is a reference to the selected layer,[br]
##this signal can be used to easly know which layer UI node is currently selected
signal layerSelected(layer : LayerUI_node)

@onready var _ghostLayerScene : PackedScene = preload("res://Scenes/layer_ghost_fill.tscn")
##This the [LayersWorkspaceArea] that this layer belongs to
var layersWorkspaceParent : LayersWorkspaceArea
##This stores reference to the layer data that is stored in the [ServerLayersStack]
var layerData : LayerData

var _createdGhost : GhostFillLayer

@onready var _visibilityButton : CheckBox = %VisibilityButton
@onready var _fillValueButton : FillValuePicker = %FillValuePicker
@onready var _texturePreview : PaintTexturePreview = %PaintTexturePreview
@onready var _fillColorButton : ColorPickerButton = %FillColorPicker
@onready var _layerNameEdit : LineEdit = %LayerName
@onready var _opacitySlider : HSlider = %OpacitySlider
@onready var _typeSwitchButton : OptionButton = %LayerType

#Used to prevent sync loop.
var _ingoreSyncOnReady : bool = true

func _ready()->void:
	_ingoreSyncOnReady = true
	pressed.connect(_layerSelected)
	updatePropertiesFromData()
	_ingoreSyncOnReady = false

func _layerSelected()->void:
	layerSelected.emit(self)

func _visibilityChanged(state : bool)->void:
	if _ingoreSyncOnReady:
		return
	layerData.visible = state
	ServerLayersStack.syncLayerProperties(get_index(),self)
	var matID : int = ServerModelHierarchy.selectedMaterialIndex
	mixer.mixInputs(matID)

func _colorChanged(newColor : Color)->void:
	if _ingoreSyncOnReady:
		return
	layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode] = newColor
	ServerLayersStack.syncLayerProperties(get_index(),self)
	var matID : int = ServerModelHierarchy.selectedMaterialIndex
	mixer.mixInputs(matID,layersWorkspaceParent.layerStackPreviewTypeMode)

func _valueChanged(newValue : float)->void:
	if _ingoreSyncOnReady:
		return
	layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode] = newValue
	ServerLayersStack.syncLayerProperties(get_index(),self)
	var matID : int = ServerModelHierarchy.selectedMaterialIndex
	mixer.mixInputs(matID,layersWorkspaceParent.layerStackPreviewTypeMode)

func _titleChanged(newTitle : String)->void:
	if _ingoreSyncOnReady:
		return
	layerData.name = newTitle
	ServerLayersStack.syncLayerProperties(get_index(),self)

func _opacityChanged(sliderValue : float)->void:
	if _ingoreSyncOnReady:
		return
	layerData.opacity = sliderValue / _opacitySlider.max_value
	ServerLayersStack.syncLayerProperties(get_index(),self)
	var matID : int = ServerModelHierarchy.selectedMaterialIndex
	mixer.mixInputs(matID)

func _typeChanged(index : int)->void:
	if _ingoreSyncOnReady:
		return
	layerData.type = index
	ServerLayersStack.syncLayerProperties(get_index(),self)
	var matID : int = ServerModelHierarchy.selectedMaterialIndex
	mixer.mixInputs(matID)

func _get_drag_data(_at_position : Vector2)->Variant:
	#Called when layer started to be dragged by cursor
	_createdGhost = _ghostLayerScene.instantiate()
	get_tree().root.add_child(_createdGhost)
	_copySize(self,_createdGhost)
	LayersWorkspaceArea.draggingAnyLayer = true
	return self

##Syncs layer's properties from the server
func updatePropertiesFromData()->void:
	self._visibilityButton.button_pressed = layerData.visible
	match layersWorkspaceParent.layerStackPreviewTypeMode:
		ServerLayersStack.layerChannels.Albedo:
			_fillValueButton.hide()
			match layerData.layerType:
				LayerData.layerTypes.fill:
					_fillColorButton.show()
					_texturePreview.hide()
					self._fillColorButton.color = layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode]
				LayerData.layerTypes.paint:
					_fillColorButton.hide()
					_texturePreview.show()
					self._texturePreview.texture = layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode]
		ServerLayersStack.layerChannels.Metalness:
			_fillColorButton.hide()
			match layerData.layerType:
				LayerData.layerTypes.fill:
					_fillValueButton.show()
					_texturePreview.hide()
					self._fillValueButton.setSliderValue(layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode])
				LayerData.layerTypes.paint:
					_fillValueButton.hide()
					_texturePreview.show()
					self._texturePreview.texture = layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode]
		ServerLayersStack.layerChannels.Roughness:
			_fillColorButton.hide()
			match layerData.layerType:
				LayerData.layerTypes.fill:
					_fillValueButton.show()
					_texturePreview.hide()
					self._fillValueButton.setSliderValue(layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode])
				LayerData.layerTypes.paint:
					_fillValueButton.hide()
					_texturePreview.show()
					self._texturePreview.texture = layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode]
		ServerLayersStack.layerChannels.Normal:
			_fillValueButton.hide()
			match layerData.layerType:
				LayerData.layerTypes.fill:
					_fillColorButton.show()
					_texturePreview.hide()
					self._fillColorButton.color = layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode]
				LayerData.layerTypes.paint:
					_fillColorButton.hide()
					_texturePreview.show()
					self._texturePreview.texture = layerData.colors[layersWorkspaceParent.layerStackPreviewTypeMode]
	self._layerNameEdit.text = layerData.name
	self._opacitySlider.value = layerData.opacity * _opacitySlider.max_value
	self._typeSwitchButton.selected = layerData.mixType

#Used to set size instead of to.size = from.size
#Because this makes Godot yell with warnings to use anchors instead ;d
func _copySize(from : Control, to : Control)->void:
	to.set_anchor_and_offset(SIDE_LEFT,from.anchor_left,from.offset_left)
	to.set_anchor_and_offset(SIDE_TOP,from.anchor_top,from.offset_top)
	to.set_anchor_and_offset(SIDE_RIGHT,from.anchor_right,from.offset_right)
	to.set_anchor_and_offset(SIDE_BOTTOM,from.anchor_bottom,from.offset_bottom)
