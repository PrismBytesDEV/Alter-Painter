extends SplitContainer
class_name AreaSplitContainer

##This is a container that splits workspaces

var _mousePos : Vector2
static var _dockOptionsPopup : PopupMenu

func _input(event : InputEvent)->void:
	if event is InputEventMouseMotion:
		_mousePos = event.position
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 2:
				if vertical:
					pass
					#print(_mousePos.y, ", ",-position.y + split_offset)
					#if abs(_mousePos.y - (-position.y + split_offset)) < 10:
						#_dockOptionsPopup.position = _mousePos
						#_dockOptionsPopup.show()
				else:
					if abs(_mousePos.x - split_offset) < 10:
						_dockOptionsPopup.position = _mousePos
						_dockOptionsPopup.show()
