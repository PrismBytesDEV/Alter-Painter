extends Node3D
class_name Astral3D

static var mesh : MeshInstance3D

func _ready():
	mesh = $Shaderball
	mesh.scale = Vector3.ONE
	if mesh.get_aabb().get_longest_axis_size() < 0.1:
		mesh.scale = Vector3.ONE * 100
	
	cameraController.mesh = mesh
	cameraController.currentCamera.recenterCamera()
