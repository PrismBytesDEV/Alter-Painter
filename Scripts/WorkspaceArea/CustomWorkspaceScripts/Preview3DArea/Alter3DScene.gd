extends Node3D
class_name Alter3DScene

static var mesh : MeshInstance3D
static var light : DirectionalLight3D

func _ready()->void:
	mesh = $Shaderball
	light = $DirectionalLight3D
	mesh.scale = Vector3.ONE
	if mesh.get_aabb().get_longest_axis_size() < 0.1:
		mesh.scale = Vector3.ONE * 100
	
	cameraController.mesh = mesh
