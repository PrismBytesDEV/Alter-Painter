@tool
class_name FillValuePicker extends Button

##Class that is used in fill layers to change their contribution to textures
##like rougness, metalness etc, where only one value is needed.

@export_range(0.0,1.0) var value : float = 0.5:
	set(new):
		value = clamp(new,0.0,1.0)

const _margin : int = 3

var _sliderPopup : PopupValueSlider

signal valueChanged(newValue : float)

func _ready()->void:
	queue_redraw()
	
	if Engine.is_editor_hint():
		return
	
	_sliderPopup = PopupValueSlider.new(true, value)
	_sliderPopup.mouse_exited.connect(_hideSlider)
	_sliderPopup.valueChanged.connect(_valueChanged)
	get_tree().current_scene.add_child.call_deferred(_sliderPopup)
	_sliderPopup.hide()

func setSliderValue(new : float)->void:
	if _sliderPopup != null:
		_sliderPopup.setSliderValue(new)

func _hideSlider()->void:
	_sliderPopup.hide()

func _valueChanged()->void:
	value = _sliderPopup.value
	self.valueChanged.emit(value)

func _pressed()->void:
	_sliderPopup.global_position = self.global_position
	_sliderPopup.show()

func _process(_delta:float)->void:
	queue_redraw()

func _draw()->void:
	var rect := Rect2(_margin,_margin,size.x - 2 * _margin,size.y - 2 * _margin)
	draw_rect(rect,Color(value,value,value),true)
