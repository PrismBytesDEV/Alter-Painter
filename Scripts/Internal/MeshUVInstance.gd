class_name MeshUVInstance extends MeshInstance3D

##A class that inherits from normal [MeshInstance3D] but adds additional functionality
## to retrieve UV coordinates from 3D position of mesh's surface.

var meshtool : MeshDataTool
 
var transform_vertex_to_global := true
 
var _face_count := 0
var _world_normals :Array[Vector3] = []
var _world_vertices := []
var _local_face_vertices := []
 
func _init()->void:
	print(self)
	meshtool = MeshDataTool.new()
	meshtool.create_from_surface(mesh, 0)  
	
	_face_count = meshtool.get_face_count()
	_world_normals.resize(_face_count)
  
	_load_mesh_data()
 
func _load_mesh_data()->void:
	for idx in range(_face_count):
		_world_normals[idx] = self.global_transform.basis * meshtool.get_face_normal(idx)
	
		var fv1 := meshtool.get_face_vertex(idx, 0)
		var fv2 := meshtool.get_face_vertex(idx, 1)
		var fv3 := meshtool.get_face_vertex(idx, 2)
		
		_local_face_vertices.append([fv1, fv2, fv3])    
		
		_world_vertices.append([
			self.global_transform.basis * meshtool.get_vertex(fv1),
			self.global_transform.basis * meshtool.get_vertex(fv2),
			self.global_transform.basis * meshtool.get_vertex(fv3),
		])
	
func get_face(point : Vector3, normal : Vector3, epsilon : float = 0.1) -> Array:
	var matches = []
	for idx in range(_face_count):
		var world_normal : Vector3 = _world_normals[idx]
	
		if !equals_with_epsilon(world_normal,self.global_transform.basis * normal, epsilon):
			continue  
		var vertices = _world_vertices[idx]    
		
		if is_point_in_triangle(point, vertices[0], vertices[1], vertices[2]) :
			var bc = cart2bary(point, vertices[0], vertices[1], vertices[2]) 
			matches.push_back([idx, vertices, bc])
	
	if matches.size() > 1:
		var closest_match
		var smallest_distance = 99999.0
		for m in matches:
			var plane := Plane(m[1][0], m[1][1], m[1][2])
			var dist : float = absf(plane.distance_to(point))
			if dist < smallest_distance:
				smallest_distance = dist
				closest_match = m
		return closest_match
		
	if matches.size() > 0:
		return matches[0]
	
	return []
 
func get_uv_coords(point : Vector3, normal : Vector3, transformVert : bool = true)->Variant:
	# Gets the uv coordinates on the mesh given a point on the mesh and normal
	# these values can be obtained from a raycast
	transform_vertex_to_global = transformVert
  
	var face : Array = get_face(point, normal)
	if face.size() < 3:
		return null
	face = face as Array
	var bc = face[2]
	
	var uv1 : Vector2 = meshtool.get_vertex_uv(_local_face_vertices[face[0]][0])
	var uv2 : Vector2 = meshtool.get_vertex_uv(_local_face_vertices[face[0]][1])
	var uv3 : Vector2 = meshtool.get_vertex_uv(_local_face_vertices[face[0]][2])
  
	return (uv1 * bc.x) + (uv2 * bc.y) + (uv3 * bc.z)  
 
func equals_with_epsilon(v1 : Vector3, v2 : Vector3, epsilon : float)->bool:
	if (v1.distance_to(v2) < epsilon):
		return true
	return false
  
func cart2bary(p : Vector3, a : Vector3, b : Vector3, c: Vector3) -> Vector3:
	var v0 : Vector3 = b - a
	var v1 : Vector3 = c - a
	var v2 : Vector3 = p - a
	var d00 : float = v0.dot(v0)
	var d01 : float = v0.dot(v1)
	var d11 : float = v1.dot(v1)
	var d20 : float = v2.dot(v0)
	var d21 : float = v2.dot(v1)
	var denom : float = d00 * d11 - d01 * d01
	var v : float = (d11 * d20 - d01 * d21) / denom
	var w : float = (d00 * d21 - d01 * d20) / denom
	var u : float = 1.0 - v - w
	return Vector3(u, v, w)
 
func transfer_point(from : Basis, to : Basis, point : Vector3) -> Vector3:
	return (to * from.inverse()) * point
  
func bary2cart(a : Vector3, b : Vector3, c: Vector3, barycentric: Vector3) -> Vector3:
	return barycentric.x * a + barycentric.y * b + barycentric.z * c
  
func is_point_in_triangle(point : Vector3, v1 : Vector3, v2 : Vector3, v3 : Vector3)->bool:
	var bc = cart2bary(point, v1, v2, v3)  
  
	if (bc.x < 0 or bc.x > 1) or (bc.y < 0 or bc.y > 1) or (bc.z < 0 or bc.z > 1):
		return false
 
	return true
