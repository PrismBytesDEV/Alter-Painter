extends Node3D
class_name Alter3DScene

static var sceneRootNode : Node3D
static var mesh : MeshInstance3D
static var light : DirectionalLight3D

func _ready()->void:
	sceneRootNode = Node3D.new()
	add_child(sceneRootNode)
	mesh = $Shaderball
	light = $DirectionalLight3D
	mesh.scale = Vector3.ONE
	if mesh.get_aabb().get_longest_axis_size() < 0.1:
		mesh.scale = Vector3.ONE * 100
	
	cameraController.mesh = mesh
