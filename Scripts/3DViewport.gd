extends Node3D

@onready var mesh : MeshInstance3D = $MeshInstance3D

func _ready():
	mesh.scale = Vector3.ONE
	if mesh.get_aabb().get_longest_axis_size() < 0.1:
		mesh.scale = Vector3.ONE * 100
