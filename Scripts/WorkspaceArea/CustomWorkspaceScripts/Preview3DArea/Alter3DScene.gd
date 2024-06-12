extends Node3D
class_name Alter3DScene

static var sceneRootNode : Node3D
static var meshNode : MeshInstance3D
static var light : DirectionalLight3D

func _ready()->void:
	sceneRootNode = %SceneRoot
	light = %MainDirectionalLight
	Alter3DScene.refreshMesh(sceneRootNode.get_child(0))

func load3DAsset(path : String)->void:
	print(path)
	var gltfDocument := GLTFDocument.new()
	var gltfState := GLTFState.new()
	
	var error := gltfDocument.append_from_file(path,gltfState)
	var gltfImportedAsset : Node3D
	if error == OK:
		gltfImportedAsset = gltfDocument.generate_scene(gltfState)
		if Alter3DScene.sceneRootNode.get_child_count() > 0:
			Alter3DScene.sceneRootNode.get_child(0).queue_free()
		Alter3DScene.sceneRootNode.add_child(gltfImportedAsset)
		#Alter3DScene.refreshMesh(gltfImportedAsset)
		#cameraController.currentCamera.recenterCamera()

static func refreshMesh(meshInst : MeshInstance3D)->void:
	meshNode = meshInst
	meshNode.scale = Vector3.ONE
	#print((Vector3.ONE * meshNode.get_aabb().get_longest_axis_size()))
	#meshNode.scale = Vector3.ONE * (1.0 / meshNode.get_aabb().get_longest_axis_size())
	#if meshNode.get_aabb().get_longest_axis_size() < 0.1:
		#meshNode.scale = Vector3.ONE * 100
	cameraController.meshNode = meshNode
	cameraController.cameraRecenter = true
