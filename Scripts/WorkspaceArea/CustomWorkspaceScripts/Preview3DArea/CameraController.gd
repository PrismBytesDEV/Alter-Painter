@tool
class_name cameraController extends Node3D

##This class have all the movement code to move the camera around the scene.

##Like the name suggests this variable defines mouse sensitivity 
@export var mouseSensitivity : float = 0.005

##Minimum distance between camera and a "hit point" of the 3D model's surface
## if the distance is equal or smaller than that, then user can't scroll closer.
static var closeMinCamDistance : float

#Length of raycast that detects whever cursor "hits" the surface of the 3D model
const _rayLength : float = 1024.0
##Defines how fast camera rotates around "hit point"
const trackballSpeed : float = 0.01

##[cameraController]'s camera.
var camera : Camera3D

var _light : DirectionalLight3D

##Position which camera rotates around when [member cameraController.CurrentMotionMode]
## is set to [param motionModes.RotateCamera]
static var mouseRayHitPosition : Vector3

##Stores information about current movement state of the [cameraController]
var CurrentMotionMode : motionModes = motionModes.None

##Available modes / states this controller can switch depending on what shortcut is pressed
enum motionModes
{
	##Default movement mode, by default it's used when user is
	## moving mouse while pressing middle mouse button.
	RotateCamera,
	##Shifts camera's position in it's local up-down left-right directions,
	## by default it's used when user presses both Shift and middle mouse button
	## while moving mouse.
	ShiftCameraPosition,
	##Rotates main light. by default it's used when user presses both Ctrl and middle mouse button
	## while moving mouse.
	RotateLight,
	##Used when no movement is happening.
	None
}

func _enter_tree()->void:
	if !Engine.is_editor_hint():
		ServerPreview3D._addCamera(self)

func _exit_tree()->void:
	if !Engine.is_editor_hint():
		ServerPreview3D._removeCamera(self)

func _ready()->void:
	
	if get_child_count() > 0:
		if get_child(0) is Camera3D:
			camera = get_child(0)
	else:
		camera = Camera3D.new()
		add_child(camera)
	camera.position = Vector3(0,0,4.0)

func _process(_delta : float)->void:
	if Engine.is_editor_hint():
		return
	
	if Alter3DScene.light != null:
		_light = Alter3DScene.light

func _physics_process(_delta : float)->void:
	if !Engine.is_editor_hint():
		Preview3DWorkspaceArea.debugTextureRect.texture = painter.texture
	var mousePos := get_viewport().get_mouse_position()
	var rayFrom := camera.project_ray_origin(mousePos)
	var rayTo := rayFrom + camera.project_ray_normal(mousePos) * _rayLength
	var space := get_world_3d().direct_space_state
	var rayParams := PhysicsRayQueryParameters3D.new()
	rayParams.from = rayFrom
	rayParams.to = rayTo
	var rayCollisionInfo := space.intersect_ray(rayParams)
	if rayCollisionInfo.size() > 0:
		mouseRayHitPosition = rayCollisionInfo.get("position")
		var mouseRayHitNormal : Vector3 = rayCollisionInfo.get("normal")
		
		var matID : int = ServerModelHierarchy.selectedMaterialIndex
		var layersStack := ServerLayersStack.materialsLayers[matID].layers
		var selectedLayerData : LayerData = layersStack[ServerLayersStack.selectedLayerIndex]
		if selectedLayerData != null:
			if selectedLayerData.layerType == LayerData.layerTypes.paint:
				if Input.is_action_pressed("paint"):
					var meshInstance : MeshUVInstance = rayCollisionInfo.get("collider").get_parent()
					if meshInstance.get_uv_coords(mouseRayHitPosition,mouseRayHitNormal) != null:
						var uvPos : Vector2 = meshInstance.get_uv_coords(mouseRayHitPosition,mouseRayHitNormal)
						painter.paint(uvPos)
						selectedLayerData.colors[0] = painter.texture
						#Preview3DWorkspaceArea.debugTextureRect.texture = painter.texture
						mixer.mixInputs(matID)
		if OS.is_debug_build():
			var config := DebugDraw3D.scoped_config()
			config.set_viewport(get_parent().get_viewport())
			#DebugDraw3D.draw_sphere(mouseRayHitPosition,0.01,Color.RED)

func _input(event : InputEvent)->void:
	if Engine.is_editor_hint():
		return
	
	var camDistance := global_position.distance_to(camera.global_position)
	var camDirection := global_position.direction_to(camera.global_position)
	
	CurrentMotionMode = motionModes.None
	if Input.is_action_pressed("RotateCamera"):
		CurrentMotionMode = motionModes.RotateCamera
	if Input.is_action_pressed("ShiftCameraPosition"):
		CurrentMotionMode = motionModes.ShiftCameraPosition
	if Input.is_action_pressed("RotateLight"):
		CurrentMotionMode = motionModes.RotateLight
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_anchorCameraCenterPoint()
			if global_position.distance_to(camera.global_position) > closeMinCamDistance:
				camera.global_position -= camDirection * (0.1 * camDistance)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_anchorCameraCenterPoint()
			camera.global_position += camDirection * (0.1 * camDistance)
		if Input.is_action_pressed("RotateCamera"):
			_anchorCameraCenterPoint()
	
	if event is InputEventMouseMotion:
		if CurrentMotionMode == motionModes.RotateCamera:
			rotate(Vector3.UP, -event.relative.x * trackballSpeed)
			rotate_object_local(Vector3.RIGHT, -event.relative.y * trackballSpeed)
		if CurrentMotionMode == motionModes.ShiftCameraPosition:
			camera.position += camera.basis.x * (-event.relative.x * camDistance * mouseSensitivity)
			camera.position += camera.basis.y * (event.relative.y * camDistance * mouseSensitivity)
		if CurrentMotionMode == motionModes.RotateLight:
			_light.rotate(Vector3.UP, event.relative.x * trackballSpeed)
			_light.rotate_object_local(Vector3.RIGHT, event.relative.y * trackballSpeed)

func _anchorCameraCenterPoint()->void:
	var ogCamGlobalPos := camera.global_position
	global_position = mouseRayHitPosition
	camera.global_position = ogCamGlobalPos

##Resets this [cameraController] and it's camera's position and rotation to it's original state.
func recenterCamera()->void:
	if Engine.is_editor_hint():
		return
	
	global_position = Vector3.ZERO
	closeMinCamDistance = 0.15
	camera.position = Vector3(0,0,closeMinCamDistance + 4.0)
	self.global_rotation = Vector3.ZERO
