extends Control
class_name WorkspaceArea

static var CurrentMouseHoverArea : WorkspaceArea

static var debugCurrentHoverArea : bool = false

enum SplitMode{
	None,VSplit,HSplit
}
static var CurrentSplitMode : SplitMode

var _mousePos : Vector2
@onready var splitLine : Line2D = %"SplitLine"
@onready var _dockOptionsPopup : PopupMenu = %DockOptionsPopup

func _ready():
	#debugCurrentHoverArea = true
	_dockOptionsPopup.id_pressed.connect(_receivePopupInfo)
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	splitLine.hide()
	CurrentSplitMode = SplitMode.None

func _mouse_entered()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE

func _input(event : InputEvent)->void:
	if event is InputEventMouseMotion:
		_mousePos = event.position
	if event is InputEventMouseButton:
		if event.pressed: 
			if event.button_index == 1:
				if CurrentSplitMode != SplitMode.None:
					CurrentSplitMode = SplitMode.None
					splitLine.hide()
			if event.button_index == 2:
				if CurrentSplitMode != SplitMode.None:
					CurrentSplitMode = SplitMode.None
					splitLine.hide()

func _process(_delta : float)-> void:
	if CurrentSplitMode != SplitMode.None:
		splitLine.visible = CurrentMouseHoverArea != null
	if CurrentMouseHoverArea != self:
		return
	if CurrentSplitMode == SplitMode.VSplit:
		var _upYPos : float = global_position.y
		var _downYPos : float = global_position.y + size.y
		splitLine.set_point_position(0,Vector2(_mousePos.x,_upYPos))
		splitLine.set_point_position(1,Vector2(_mousePos.x,_downYPos))
	elif CurrentSplitMode == SplitMode.HSplit:
		var _leftXPos : float = global_position.x
		var _rightXPos : float = global_position.x + size.x
		splitLine.set_point_position(0,Vector2(_leftXPos,_mousePos.y))
		splitLine.set_point_position(1,Vector2(_rightXPos,_mousePos.y))

func _receivePopupInfo(index : int)->void:
	match index:
		0:# Vertical Split
			CurrentSplitMode = SplitMode.VSplit
			splitLine.show()
		1:# Horizontal Split
			CurrentSplitMode = SplitMode.HSplit
			splitLine.show()
		2:# Join Areas
			CurrentSplitMode = SplitMode.None
			splitLine.hide()
		3:# Swap Areas
			CurrentSplitMode = SplitMode.None
			splitLine.hide()
