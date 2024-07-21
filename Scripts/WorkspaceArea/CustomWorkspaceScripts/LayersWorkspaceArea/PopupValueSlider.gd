class_name PopupValueSlider extends Panel

##This is custom made slider inside a panel that looks like a popup. 
##The main usage for this node is for changing the value of Metallnes or Roughness
## in the fill layer, or to edit the opacity. 

var _sliderNode : HSlider 
var value : float:
	set(new):
		value = clamp(new,0,1.0)

var isPercentage : bool

signal valueChanged

func _init(usePercentage : bool, defaultValue : float = 1.0)->void:
	isPercentage = usePercentage
	value = defaultValue

func _ready()->void:
	size = Vector2i(128,20)
	_sliderNode = HSlider.new()
	_sliderNode.value = value * _sliderNode.max_value
	_sliderNode.value_changed.connect(_sliderValueChanged)
	add_child(_sliderNode)
	_sliderNode.mouse_filter = Control.MOUSE_FILTER_PASS
	_sliderNode.set_anchor_and_offset(SIDE_LEFT,0,10.0)
	_sliderNode.set_anchor_and_offset(SIDE_TOP,0,0)
	_sliderNode.set_anchor_and_offset(SIDE_RIGHT,1,-10.0)
	_sliderNode.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	_sliderNode.grow_horizontal = GROW_DIRECTION_BOTH
	_sliderNode.grow_vertical = GROW_DIRECTION_BOTH

func setSliderValue(new : float)->void:
	if _sliderNode != null:
		_sliderNode.value = new * _sliderNode.max_value

func _sliderValueChanged(newValue : float)->void:
	if isPercentage:
		value = newValue / _sliderNode.max_value
	else:
		value = newValue
	valueChanged.emit()
