extends MeshInstance3D

@export var uvVertexCoords : Array[Vector2] = []
var vertexPositions : Array[Vector3] = []

func _ready():
	uvVertexCoords.clear()
	vertexPositions.clear()
	var mTool : MeshDataTool = MeshDataTool.new()
	mTool.create_from_surface(mesh,0)
	var vertUVPos : Array[Vector2]
	for faceID in mTool.get_face_count():
		for faceVertIndex in 3:
			var vert = mTool.get_face_vertex(faceID,faceVertIndex)
			uvVertexCoords.append(mTool.get_vertex_uv(vert))
			print(faceVertIndex,faceID)
	for i in uvVertexCoords:
		vertexPositions.append(Vector3(i.x,0,i.y))
	
