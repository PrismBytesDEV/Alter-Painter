@tool
extends Marker3D

@export var farMaxCamDistance : float = 15
@export var closeMinCamDistance : float = 2

const trackballSpeed : float = 0.01
var trackModelMode : bool = false
var canRotateLight : bool = false
var rotateLightMode : bool = false
var cameraDistance : float = 2
@onready var Camera : Camera3D = $Camera3D
@onready var mesh : MeshInstance3D = $"../MeshInstance3D"

@onready var light : DirectionalLight3D = $"../DirectionalLight3D"

func _ready():
	recenterCamera()

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_SHIFT:
			canRotateLight = false
			if event.pressed:
				canRotateLight = true
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if cameraDistance > closeMinCamDistance:
				cameraDistance -= 0.1
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if cameraDistance < farMaxCamDistance:
				cameraDistance += 0.1
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			trackModelMode = false
			rotateLightMode = false
			if event.pressed:
				if canRotateLight:
					rotateLightMode = true
				else:
					trackModelMode = true
	
	Camera.position = Vector3(0,0,cameraDistance)
	
	if event is InputEventMouseMotion:
		if trackModelMode:
			rotate(Vector3.UP, -event.relative.x * trackballSpeed)
			rotate_object_local(Vector3.RIGHT, -event.relative.y * trackballSpeed)
		if rotateLightMode:
			light.rotate(Vector3.UP, event.relative.x * trackballSpeed)
			light.rotate_object_local(Vector3.RIGHT, event.relative.y * trackballSpeed)

func recenterCamera():
	position = mesh.get_aabb().get_center()
