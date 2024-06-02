extends SplitContainer
class_name AreaSplitContainer

var _mousePos : Vector2i

@onready var _dockOptionsPopup : PopupMenu = %DockOptionsPopup

func _input(event):
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
					print("m = ",_mousePos.y, ", off = ", size.y + split_offset)
					if absi(_mousePos.y - (position.y + size.y + split_offset)) < 10:
						_dockOptionsPopup.position = _mousePos
						_dockOptionsPopup.show()
						print("vertical POPUP")
				else:
					#print("m = ",_mousePos.x, ", off = ", split_offset)
					if absi(_mousePos.x - split_offset) < 10:
						_dockOptionsPopup.position = _mousePos
						_dockOptionsPopup.show()
