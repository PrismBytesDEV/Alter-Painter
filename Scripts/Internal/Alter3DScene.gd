class_name Alter3DScene extends Node3D

##This class exposes 3D scene's informations.[br] 
##the scene is visible in all [Preview3DWorkspaceArea]

##This is the root of a 3D scene. It's the parent of imported 3D model,
##but it's not a root of the entire application's scene tree.
##To get that, simply use [member get_tree().current_scene]
static var sceneRootNode : Node3D
##This is the root of imported 3D model.
##you can use it to idduno destroy it with queue_free() or something xD
##although I don't recommend that
static var modelRootNode : Node
##Reference to the main light source in the scene
##Of course enviroment can also contribute to the scene's lighting
static var light : DirectionalLight3D
##List of all PBR materials that are used by the imported 3D model
static var modelMaterials : Array[StandardMaterial3D]

static var _unnamedMaterialCounter : int

func _ready()->void:
	sceneRootNode = %SceneRoot
	light = %MainDirectionalLight
	Alter3DScene.refreshMesh(sceneRootNode.get_child(0))
	Mixer.new()

##Loads a 3D model from specified [param path][br]
##And instantiates it as a child of [member Alter3DScene.sceneRootNode]
##[br][color=#edcb6d][b]IMPORTANT[/b][br][/color]
##Currently only .glb and .gltf files are supported
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

##Loads all the necesary data from [member Alter3DScene.modelRootNode][br]
##And clears everything from the project like for example all the layers stacks and their data
##will be lost after calling this method.[br][br]
##Usually this is used when creating completly new project
static func refreshMesh(meshInst : Node)->void:
	modelRootNode = meshInst
	modelMaterials.clear()
	_unnamedMaterialCounter = 0
	ServerModelHierarchy.selectedMaterialName = ""
	ServerModelHierarchy.selectedMaterialIndex = 0
	ServerLayersStack._materialsLoaded = false
	ServerLayersStack.materialsLayers.clear()
	Alter3DScene.loadMaterials(modelRootNode)
	ServerLayersStack._materialsLoaded = true
	Alter3DScene._addAssetColliders(modelRootNode)
	
	ServerPreview3D.recenterCameras()
	ServerModelHierarchy.refreshDisplayData()
	ServerLayersStack.cleanWorkspacesLayers()
	Alter3DScene._loadModelsTexturesIntoLayersStacks()

##Loads materials into [member Alter3DScene.modelMaterials] 
##from [member Alter3DScene.modelRootNode]
static func loadMaterials(assetRoot : Node)->void:
	for child in assetRoot.get_children():
		loadMaterials(child)
	if assetRoot is MeshInstance3D:
		var theMat : StandardMaterial3D
		for surfaceID : int in assetRoot.mesh.get_surface_count():
			if !modelMaterials.has(assetRoot.mesh.surface_get_material(surfaceID)):
				theMat = assetRoot.mesh.surface_get_material(surfaceID)
				if theMat.resource_name.is_empty():
					theMat.resource_name = "<Unnamed Material> " + str(_unnamedMaterialCounter)
					_unnamedMaterialCounter += 1
				if ServerModelHierarchy.selectedMaterialName.is_empty():
					ServerModelHierarchy.selectedMaterialName = theMat.resource_name
				modelMaterials.append(theMat)
				ServerLayersStack._appendNewMaterialLayersStack()

#This funtion creates static body and collision shapes
#so that a raycast can shoot out of camera, allowing user to orbit around
#the place where mouse is currently hovering over 
static func _addAssetColliders(assetRoot : Node)->void:
	for child in assetRoot.get_children():
		_addAssetColliders(child)
	if assetRoot is MeshInstance3D:
		assetRoot.create_trimesh_collision()

static func _loadModelsTexturesIntoLayersStacks()->void:
	#This needs to be redone when paint layers will be added
	for matID : int in modelMaterials.size():
		var theMat := modelMaterials[matID]
		
		var colorsDict : Dictionary = {
			ServerLayersStack.layerChannels.Albedo : theMat.albedo_color,
			ServerLayersStack.layerChannels.Roughness : theMat.roughness,
			ServerLayersStack.layerChannels.Metalness : theMat.metallic
		}
		if theMat.albedo_texture == null:
			var albedoImage := Image.create(1,1,false,Image.FORMAT_RGBA8)
			albedoImage.fill(theMat.albedo_color)
			theMat.albedo_texture = ImageTexture.create_from_image(albedoImage)
		theMat.albedo_color = Color.WHITE
		if theMat.metallic_texture == null:
			var metallicImage := Image.create(1,1,false,Image.FORMAT_RGBA8)
			metallicImage.fill(Color.WHITE * theMat.metallic)
			theMat.metallic_texture = ImageTexture.create_from_image(metallicImage)
		theMat.metallic = 1.0
		ServerLayersStack.addLayer(matID,true,colorsDict,"Imported layer " + theMat.resource_name,1.0,0)
