extends MeshInstance3D


func _ready():
	
	var mTool : MeshDataTool = MeshDataTool.new()
	mTool.create_from_surface(mesh,0)
	var vertUVPos : Array[Vector2]
	for i in mTool.get_face_count():
		var vertI : int = 0
		while mTool.get_face_vertex(i,vertI) != null:
			pass
	
	pass
