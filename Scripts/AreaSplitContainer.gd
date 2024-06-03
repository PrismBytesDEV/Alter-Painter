extends SplitContainer
class_name AreaSplitContainer

var _mousePos : Vector2

@onready var _dockOptionsPopup : PopupMenu = %DockOptionsPopup

func _input(event : InputEvent)->void:
	if event is InputEventMouseMotion:
		_mousePos = event.position
	if event is InputEventMouseButton:
		if event.button_index == 2:
			if event.pressed:
				if vertical:
					if abs(_mousePos.y - (position.y + size.y + split_offset)) < 10:
						_dockOptionsPopup.position = _mousePos
						_dockOptionsPopup.show()
				else:
					if abs(_mousePos.x - split_offset) < 10:
						_dockOptionsPopup.position = _mousePos
						_dockOptionsPopup.show()
