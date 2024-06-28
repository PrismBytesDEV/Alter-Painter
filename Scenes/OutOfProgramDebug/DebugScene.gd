@tool
extends Node3D

var aabb : AABB

@export var objects : Array[MeshInstance3D]

func _ready():
	aabb = objects[0].get_aabb()
	aabb.position = Vector3.ZERO
	aabb.end = Vector3.ZERO

func rotateVector(ogVec : Vector3, node : Node3D)->Vector3:
	ogVec = ogVec.rotated(node.basis.x.normalized(),node.rotation.x)
	ogVec = ogVec.rotated(node.basis.y.normalized(),node.rotation.y)
	ogVec = ogVec.rotated(node.basis.z.normalized(),node.rotation.z)
	
	return ogVec

func _process(_delta):
	var debugDrawSConfig : DebugDraw3DScopeConfig
	debugDrawSConfig = DebugDraw3D.new_scoped_config()
	debugDrawSConfig.set_thickness(0.005)
	
	for node in objects:
		var nodeAABB : AABB = node.get_aabb()
		
		
		
		
		#print(nodeAABB.size)
		
		var parentRotatedScale := node.get_parent_node_3d().scale
		parentRotatedScale = rotateVector(parentRotatedScale,node.get_parent_node_3d())
		
		var rotatedScale := node.scale * node.get_parent_node_3d().scale
		#rotatedScale = rotateVector(rotatedScale,node)
		
		nodeAABB.position *= rotatedScale
		nodeAABB.size *= rotatedScale
		
		nodeAABB.position = rotateVector(nodeAABB.position,node)
		nodeAABB.size = rotateVector(nodeAABB.size,node)
		
		var rotatedPosition : Vector3 = node.global_position
		rotatedPosition = rotateVector(rotatedPosition,node)
		nodeAABB.position += rotatedPosition
		
		nodeAABB = nodeAABB.abs()
		
		aabb.merge(nodeAABB)
		DebugDraw3D.draw_aabb(nodeAABB)
	#DebugDraw3D.draw_aabb(aabb)
	
