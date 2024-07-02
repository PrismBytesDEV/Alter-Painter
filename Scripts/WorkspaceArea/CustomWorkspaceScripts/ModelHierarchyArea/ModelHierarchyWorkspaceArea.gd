extends WorkspaceArea
class_name ModelHierarchyWorkspaceArea

@onready var treeDisplay : Tree = $Tree

@onready var rootIcon : Texture2D = preload("res://textures/icons/ModelRoot.svg")
@onready var meshIcon : Texture2D = preload("res://textures/icons/BoxShape3D.svg")
@onready var materialIcon : Texture2D = preload("res://textures/icons/Material.svg")
@onready var uknownMaterialIcon : Texture2D = preload("res://textures/icons/MaterialUnnamed.svg")
@onready var importFailIcon : Texture2D = preload("res://textures/icons/ImportFail.svg")
@onready var importedNotMesh : Texture2D = preload("res://textures/icons/ImportedNotMesh.svg")
@onready var meshVisibleIcon : Texture2D = preload("res://textures/icons/GuiVisibilityVisible.svg")
@onready var meshHiddenIcon : Texture2D = preload("res://textures/icons/GuiVisibilityHidden.svg")

var lastButtonID : int
var _visibleStateLookupTable : Dictionary
var _objectsLookupTable : Dictionary

var _undefinedMaterialCounter : int

var dataPreviewModeButton : OptionButton

enum dataPreviewMODES {
	ALL,
	OBJECTS_ONLY,
	MATERIALS_ONLY
}

enum itemMeta {
	Root,
	MeshObj,
	Mat,
	Other
}

var dataPreviewMode : int

func _init()->void:
	name = "ModelHierarchyArea"
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func _enter_tree()->void:
	ServerModelHierarchy.addDisplayWorkspaceArea(self)

func _exit_tree()->void:
	ServerModelHierarchy.removeDisplayWorkspaceArea(self)

func _ready()->void:
	setupWorkspaceArea()
	
	dataPreviewModeButton = OptionButton.new()
	dataPreviewModeButton.fit_to_longest_item = false
	dataPreviewModeButton.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN + SIZE_EXPAND
	dataPreviewModeButton.add_item("All")
	dataPreviewModeButton.add_item("Objects Only")
	dataPreviewModeButton.add_item("Materials Only")
	dataPreviewModeButton.selected = 0
	areaOptionsContainer.add_child(dataPreviewModeButton)
	dataPreviewModeButton.item_selected.connect(switchDisplayDataMode)
	
	treeDisplay.button_clicked.connect(visibilityButtonPressed)
	treeDisplay.item_selected.connect(treeDisplayItemSelected)
	if Alter3DScene.assetRootNode != null:
		refreshDisplay()

func _mouse_entered()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE

func switchDisplayDataMode(mode : int)->void:
	dataPreviewMode = mode
	refreshDisplay()

func refreshDisplay()->void:
	treeDisplay.clear()
	_objectsLookupTable.clear()
	_visibleStateLookupTable.clear()
	_undefinedMaterialCounter = 0
	lastButtonID = 0
	loadTreeDisplayData()

func loadTreeDisplayData()->void:
	match dataPreviewMode:
		dataPreviewMODES.ALL:
			_loadAllDataDisplay(Alter3DScene.assetRootNode,true)
		dataPreviewMODES.OBJECTS_ONLY:
			_loadAllDataDisplay(Alter3DScene.assetRootNode,false)
		dataPreviewMODES.MATERIALS_ONLY:
			_loadMaterialsDisplay()

func _loadAllDataDisplay(rootNode : Node,includeMaterial : bool = true, iterationParent : TreeItem = null)->void:
	if rootNode is StaticBody3D:
		return
	
	var createdItem : TreeItem
	if iterationParent != null:
		createdItem = treeDisplay.create_item(iterationParent)
		createdItem.set_text(0,rootNode.name)
	else:
		createdItem = treeDisplay.create_item()
		createdItem.set_text(0,"Root")
	
	if rootNode is MeshInstance3D:
		createdItem.set_icon(0,meshIcon)
		createdItem.set_meta("type",itemMeta.MeshObj)
		
		var objectVisiblityIcon : Texture2D
		if rootNode.visible:
			objectVisiblityIcon = meshVisibleIcon
		else:
			objectVisiblityIcon = meshHiddenIcon
		
		createdItem.add_button(1,objectVisiblityIcon,lastButtonID,false)
		
		_visibleStateLookupTable.merge({lastButtonID : rootNode.visible})
		_objectsLookupTable.merge({lastButtonID : rootNode})
		
		lastButtonID += 1
		
		if includeMaterial:
			for surfID : int in rootNode.mesh.get_surface_count():
				var matItem : TreeItem
				
				var mat : Material
				var matIcon : Texture2D
				
				if rootNode.mesh.surface_get_material(surfID) != null:
					matItem = treeDisplay.create_item(createdItem)
					mat = rootNode.mesh.surface_get_material(surfID)
					matItem.set_meta("type",itemMeta.Mat)
				
				if mat.resource_name.begins_with("<"):
					matIcon = uknownMaterialIcon
				else:
					matIcon = materialIcon
				
				if mat.resource_name == ServerModelHierarchy.selectedMaterialName:
					matItem.set_custom_color(0,ServerModelHierarchy.selectedMatThemeColor)
				
				matItem.set_text(0,mat.resource_name)
				matItem.set_icon(0,matIcon)
	else:
		createdItem.set_meta("type",itemMeta.Other)
		if rootNode is Node3D:
			createdItem.set_icon(0,importedNotMesh)
		if rootNode is Control:
			createdItem.set_icon(0,importFailIcon)
		if rootNode is Node2D:
			createdItem.set_icon(0,importFailIcon)
		if rootNode is GPUParticles3D or GPUParticlesAttractor3D or GPUParticlesCollision3D:
			createdItem.set_icon(0,importFailIcon)
		
		if iterationParent == null:
			createdItem.set_meta("type",itemMeta.Root)
			createdItem.set_icon(0,rootIcon)
	for child in rootNode.get_children():
		_loadAllDataDisplay(child,includeMaterial,createdItem)

func _loadMaterialsDisplay()->void:
	var rootItem := treeDisplay.create_item()
	rootItem.set_meta("type",itemMeta.Root)
	rootItem.set_text(0,"Materials")
	for mat : Material in Alter3DScene.assetMaterials:
		var materialItem := treeDisplay.create_item()
		materialItem.set_meta("type",itemMeta.Mat)
		
		var matIcon : Texture2D
		
		if mat.resource_name.begins_with("<"):
			matIcon = uknownMaterialIcon
		else:
			matIcon = materialIcon
		
		if mat.resource_name == ServerModelHierarchy.selectedMaterialName:
			materialItem.set_custom_color(0,ServerModelHierarchy.selectedMatThemeColor)
		
		materialItem.set_text(0,mat.resource_name)
		materialItem.set_icon(0,matIcon)

func treeDisplayItemSelected()->void:
	var selectedItem := treeDisplay.get_selected()
	if selectedItem.get_meta("type") == itemMeta.Mat:
		ServerModelHierarchy.selectedMaterialName = selectedItem.get_text(0)
		ServerModelHierarchy.refreshSelectedMaterialItems()

func changeItemTreeColors_init()->void:
	_changeItemTreeColors(treeDisplay.get_root())

func _changeItemTreeColors(rootItem : TreeItem)->void:
	if rootItem.get_text(0) != ServerModelHierarchy.selectedMaterialName:
		rootItem.clear_custom_color(0)
	else:
		rootItem.set_custom_color(0,ServerModelHierarchy.selectedMatThemeColor)
	for child : TreeItem in rootItem.get_children():
		_changeItemTreeColors(child)

func visibilityButtonPressed(_item: TreeItem, _column: int, id: int, _mouse_button_index: int)->void:
	var buttonState : bool = !_visibleStateLookupTable[id]
	_visibleStateLookupTable[id] = buttonState
	
	var meshObject : Node = _objectsLookupTable[id]
	meshObject.visible = buttonState
	
	ServerModelHierarchy.refreshDisplayData()
