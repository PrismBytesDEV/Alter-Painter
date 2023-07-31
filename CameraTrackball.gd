@tool
extends Marker3D

const trackballSpeed : float = 0.01
var trackModelMode : bool = false
var canRotateLight : bool = false
var rotateLightMode : bool = false

var light : DirectionalLight3D

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			canRotateLight = false
			if event.pressed:
				canRotateLight = true
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if $Camera.size > 4:
				$Camera.size -= 1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if $Camera.size < 10:
				$Camera.size += 1
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			trackModelMode = false
			rotateLightMode = false
			if event.pressed:
				if canRotateLight:
					rotateLightMode = true
				else:
					trackModelMode = true
	
	$"../SubViewport/RenderCamera".size = $Camera.size - 3
	
	if event is InputEventMouseMotion:
		if trackModelMode:
			rotate(Vector3.UP, -event.relative.x * trackballSpeed)
			rotate_object_local(Vector3.RIGHT, -event.relative.y * trackballSpeed)
			$"../SubViewport/RenderCamera".global_position = $Camera.global_position
			$"../SubViewport/RenderCamera".global_rotation = $Camera.global_rotation
		if rotateLightMode:
			light.rotate(Vector3.UP, event.relative.x * trackballSpeed)
			light.rotate_object_local(Vector3.RIGHT, event.relative.y * trackballSpeed)
