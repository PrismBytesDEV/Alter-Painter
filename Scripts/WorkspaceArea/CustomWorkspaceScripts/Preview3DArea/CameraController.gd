@tool
extends Marker3D
class_name cameraController

@export var mouseSensitivity : float = 0.005

static var farMaxCamDistance : float
static var closeMinCamDistance : float

const rayLength : float = 1024.0
const trackballSpeed : float = 0.01

var camera : Camera3D
static var currentCamera : cameraController

var light : DirectionalLight3D

static var mouseRayHitPosition : Vector3

enum motionModes
{
	RotateCamera,
	ShiftCameraPosition,
	RotateLight,
	None
}

var middleClickMotionMode : motionModes = motionModes.None

func _enter_tree()->void:
	if !Engine.is_editor_hint():
		ServerCamera.addCamera(self)

func _exit_tree()->void:
	if !Engine.is_editor_hint():
		ServerCamera.removeCamera(self)

func _ready()->void:
	
	if get_child_count() > 0:
		if get_child(0) is Camera3D:
			camera = get_child(0)
	else:
		camera = Camera3D.new()
		add_child(camera)
	camera.position = Vector3(0,0,4.0)
	currentCamera = self

func _process(_delta : float)->void:
	if Engine.is_editor_hint():
		return
	
	if Alter3DScene.light != null:
		light = Alter3DScene.light

func _physics_process(_delta : float)->void:
	var mousePos := get_viewport().get_mouse_position()
	var rayFrom := camera.project_ray_origin(mousePos)
	var rayTo := rayFrom + camera.project_ray_normal(mousePos) * rayLength
	var space := get_world_3d().direct_space_state
	var rayParams := PhysicsRayQueryParameters3D.new()
	rayParams.from = rayFrom
	rayParams.to = rayTo
	var rayCollisionInfo := space.intersect_ray(rayParams)
	if rayCollisionInfo.size() > 0:
		mouseRayHitPosition = rayCollisionInfo.get("position")
		if OS.is_debug_build():
			var config := DebugDraw3D.scoped_config()
			config.set_viewport(get_parent().get_viewport())
			#DebugDraw3D.draw_sphere(mouseRayHitPosition,0.01,Color.RED)

func _input(event : InputEvent)->void:
	if Engine.is_editor_hint():
		return
	
	var camDistance := global_position.distance_to(camera.global_position)
	var camDirection := global_position.direction_to(camera.global_position)
	
	middleClickMotionMode = motionModes.None
	if Input.is_action_pressed("RotateCamera"):
		middleClickMotionMode = motionModes.RotateCamera
	if Input.is_action_pressed("ShiftCameraPosition"):
		middleClickMotionMode = motionModes.ShiftCameraPosition
	if Input.is_action_pressed("RotateLight"):
		middleClickMotionMode = motionModes.RotateLight
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			anchorCameraCenterPoint()
			if global_position.distance_to(camera.global_position) > closeMinCamDistance:
				camera.global_position -= camDirection * (0.1 * camDistance)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			anchorCameraCenterPoint()
			camera.global_position += camDirection * (0.1 * camDistance)
		if Input.is_action_pressed("RotateCamera"):
			anchorCameraCenterPoint()
	
	if event is InputEventMouseMotion:
		if middleClickMotionMode == motionModes.RotateCamera:
			rotate(Vector3.UP, -event.relative.x * trackballSpeed)
			rotate_object_local(Vector3.RIGHT, -event.relative.y * trackballSpeed)
		if middleClickMotionMode == motionModes.ShiftCameraPosition:
			camera.position += camera.basis.x * (-event.relative.x * camDistance * mouseSensitivity)
			camera.position += camera.basis.y * (event.relative.y * camDistance * mouseSensitivity)
		if middleClickMotionMode == motionModes.RotateLight:
			light.rotate(Vector3.UP, event.relative.x * trackballSpeed)
			light.rotate_object_local(Vector3.RIGHT, event.relative.y * trackballSpeed)

func anchorCameraCenterPoint()->void:
	var ogCamGlobalPos := camera.global_position
	global_position = mouseRayHitPosition
	camera.global_position = ogCamGlobalPos

func recenterCamera()->void:
	if Engine.is_editor_hint():
		return
	
	global_position = Vector3.ZERO
	closeMinCamDistance = 0.15
	camera.position = Vector3(0,0,closeMinCamDistance + 4.0)
	self.global_rotation = Vector3.ZERO
