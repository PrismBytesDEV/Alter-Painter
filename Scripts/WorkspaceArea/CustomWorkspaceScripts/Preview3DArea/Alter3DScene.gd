class_name Alter3DScene extends Node3D

static var sceneRootNode : Node3D
static var assetRootNode : Node
static var light : DirectionalLight3D

static var assetMaterials : Array[StandardMaterial3D]
static var _unnamedMaterialCounter : int

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
		Alter3DScene.sceneRootNode.global_position = Vector3.ZERO
		
		Alter3DScene.refreshMesh(gltfImportedAsset)
		#cameraController.currentCamera.recenterCamera()

static func refreshMesh(meshInst : Node)->void:
	assetRootNode = meshInst
	assetMaterials.clear()
	_unnamedMaterialCounter = 0
	ServerModelHierarchy.selectedMaterialName = ""
	ServerLayersStack.materialsLoaded = false
	ServerLayersStack.materialsLayers.clear()
	Alter3DScene.loadMaterials(assetRootNode)
	ServerLayersStack.materialsLoaded = true
	Alter3DScene.addAssetColliders(assetRootNode)
	
	ServerCamera.recenterCameras()
	ServerModelHierarchy.refreshDisplayData()
	ServerLayersStack.cleanWorkspacesLayers()

static func loadMaterials(assetRoot : Node)->void:
	for child in assetRoot.get_children():
		loadMaterials(child)
	if assetRoot is MeshInstance3D:
		var theMat : Material
		for surfaceID : int in assetRoot.mesh.get_surface_count():
			if !assetMaterials.has(assetRoot.mesh.surface_get_material(surfaceID)):
				theMat = assetRoot.mesh.surface_get_material(surfaceID)
				if theMat.resource_name.is_empty():
					theMat.resource_name = "<Unnamed Material> " + str(_unnamedMaterialCounter)
					_unnamedMaterialCounter += 1
				if ServerModelHierarchy.selectedMaterialName.is_empty():
					ServerModelHierarchy.selectedMaterialName = theMat.resource_name
				assetMaterials.append(theMat)
				ServerLayersStack.appendNewMaterialLayersStack()

static func addAssetColliders(assetRoot : Node)->void:
	for child in assetRoot.get_children():
		addAssetColliders(child)
	if assetRoot is MeshInstance3D:
		assetRoot.create_trimesh_collision()

#static func init_recalculateFocusAABB(assetRoot : Node3D)->void:
	#focusAABB.position = Vector3.ZERO
	#focusAABB.end = Vector3.ZERO
	#focusAABB.size = Vector3.ZERO
	#loadedAABBs.clear()
	#loadedAABBs = []
	#Alter3DScene.recalculateFocusAABB(assetRoot, assetRoot.scale)
#
#static func recalculateFocusAABB(assetRoot : Node3D, size : Vector3 = Vector3.ONE)->void:
	#if assetRoot is Node3D:
		#size *= assetRoot.scale
	#if assetRoot.get_child_count() > 0:
		#for child in assetRoot.get_children():
			#Alter3DScene.recalculateFocusAABB(child,size)
	#if assetRoot is MeshInstance3D:
		#var assetAABB : AABB = assetRoot.get_aabb()
		#var rotatedPosition : Vector3 = assetRoot.global_position
		#rotatedPosition = rotatedPosition.rotated(Vector3.RIGHT,assetRoot.rotation.x)
		#rotatedPosition = rotatedPosition.rotated(Vector3.UP,assetRoot.rotation.y)
		#rotatedPosition = rotatedPosition.rotated(Vector3.BACK,assetRoot.rotation.z)
		#print(rotatedPosition)
		#
		#assetAABB.position += rotatedPosition
		#assetAABB.end += rotatedPosition
		#
		#assetAABB.position *= size
		#assetAABB.size *= size
		#
		#assetAABB.position = assetAABB.position.rotated(Vector3.RIGHT,assetRoot.rotation.x)
		#assetAABB.position = assetAABB.position.rotated(Vector3.UP,assetRoot.rotation.y)
		#assetAABB.position = assetAABB.position.rotated(Vector3.BACK,assetRoot.rotation.z)
		#
		#assetAABB.size = assetAABB.size.rotated(Vector3.RIGHT,assetRoot.rotation.x)
		#assetAABB.size = assetAABB.size.rotated(Vector3.UP,assetRoot.rotation.y)
		#assetAABB.size = assetAABB.size.rotated(Vector3.BACK,assetRoot.rotation.z)
		#
		#
		#
		#assetAABB = assetAABB.abs()
		#loadedAABBs.append(assetAABB)
		#
		#focusAABB = focusAABB.merge(assetAABB)
		#assetRoot.create_trimesh_collision()
	#
