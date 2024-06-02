extends SplitContainer
class_name AreaSplitContainer

var _mousePos : Vector2i

@onready var _dockOptionsPopup : PopupMenu = %DockOptionsPopup
@onready var splitLine : Line2D = %"SplitLine"

enum SplitMode {
	None,VSplit,HSplit
}

static var CurrentSplitMode : SplitMode
static var CurrentMouseEnteredArea : AreaSplitContainer

func _ready()->void:
	_dockOptionsPopup.id_pressed.connect(_receivePopupInfo)
	splitLine.hide()
	CurrentSplitMode = SplitMode.None
	self.mouse_entered.connect(self._mouseEntered)
	self.mouse_exited.connect(self._mouseExited)

func _input(event : InputEvent)->void:
	if event is InputEventMouseMotion:
		_mousePos = event.position
	if event is InputEventMouseButton:
		if event.button_index == 2:
			var horizontalMousePos := Vector2(_mousePos.x,0)
			var horizontalSplitOffset := Vector2(split_offset,0)
			var verticalMousePos := Vector2(0,_mousePos.y)
			var verticalSplitOffset := Vector2(0,split_offset)
			if event.pressed:
				if vertical:
					if absi(_mousePos.y - (position.y + size.y + split_offset)) < 10:
						_dockOptionsPopup.position = _mousePos
						_dockOptionsPopup.show()
				else:
					if absi(_mousePos.x - split_offset) < 10:
						_dockOptionsPopup.position = _mousePos
						_dockOptionsPopup.show()

func _mouseEntered()->void:
	CurrentMouseEnteredArea = self
	return
	self.modulate = Color.MAGENTA

func _mouseExited()->void:
	return
	self.modulate = Color.WHITE

func _process(_delta : float)->void:
	if CurrentMouseEnteredArea != self:
		return
	if CurrentSplitMode == SplitMode.VSplit:
		var upYPos : int = CurrentMouseEnteredArea.global_position.y
		var downYPos : int = CurrentMouseEnteredArea.global_position.y + CurrentMouseEnteredArea.size.y
		splitLine.set_point_position(0,Vector2i(_mousePos.x,upYPos))
		splitLine.set_point_position(1,Vector2i(_mousePos.x,downYPos))
	elif CurrentSplitMode == SplitMode.HSplit:
		pass

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
