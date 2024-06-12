@tool
extends Marker3D
class_name cameraController

static var farMaxCamDistance : float
static var closeMinCamDistance : float

const trackballSpeed : float = 0.01
var trackModelMode : bool = false
var canRotateLight : bool = false
var rotateLightMode : bool = false
var cameraDistance : float = 2
var Camera : Camera3D
static var currentCamera : cameraController

static var meshNode : MeshInstance3D

var light : DirectionalLight3D

static var cameraRecenter : bool = false

func _ready()->void:
	if get_child_count() > 0:
		if get_child(0) is Camera3D:
			Camera = get_child(0)
	else:
		Camera = Camera3D.new()
		add_child(Camera)
	Camera.position = Vector3(0,0,4.0)
	currentCamera = self

func _process(_delta : float)->void:
	if Engine.is_editor_hint():
		return
	print(cameraDistance)
	print("min: ", closeMinCamDistance)
	print("max: ", farMaxCamDistance)
	if cameraRecenter:
		recenterCamera()
		cameraRecenter = false
	
	if Alter3DScene.light != null:
		light = Alter3DScene.light

func _input(event : InputEvent)->void:
	if Engine.is_editor_hint():
		return
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

func recenterCamera()->void:
	if Engine.is_editor_hint():
		return
	var meshAABB := meshNode.get_aabb()
	position = meshAABB.get_center()
	closeMinCamDistance = (meshAABB.size.length())
	farMaxCamDistance = closeMinCamDistance * 4
	cameraDistance = (closeMinCamDistance + farMaxCamDistance) / 2.0
	Camera.position = Vector3(0,0,cameraDistance)
