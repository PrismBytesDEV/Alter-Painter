class_name ModelHierarchyWorkspaceArea extends WorkspaceArea

##This [WorkspaceArea] allows user to hide/show different objects of imported 3D model
## and allows to select the material that will be editred

@onready var _treeDisplay : Tree = $Tree

@onready var _rootIcon : Texture2D = preload("res://textures/icons/ModelRoot.svg")
@onready var _meshIcon : Texture2D = preload("res://textures/icons/BoxShape3D.svg")
@onready var _materialIcon : Texture2D = preload("res://textures/icons/Material.svg")
@onready var _uknownMaterialIcon : Texture2D = preload("res://textures/icons/MaterialUnnamed.svg")
@onready var _importFailIcon : Texture2D = preload("res://textures/icons/ImportFail.svg")
@onready var _importedNotMesh : Texture2D = preload("res://textures/icons/ImportedNotMesh.svg")
@onready var _meshVisibleIcon : Texture2D = preload("res://textures/icons/GuiVisibilityVisible.svg")
@onready var _meshHiddenIcon : Texture2D = preload("res://textures/icons/GuiVisibilityHidden.svg")

var _lastButtonID : int
var _visibleStateLookupTable : Dictionary
var _objectsLookupTable : Dictionary

var _undefinedMaterialCounter : int

##This is the button that allow user to switch between diffent preview modes
## list of all available preview modes: [enum ModelHierarchyWorkspaceArea.dataPreviewMODES]
var dataPreviewModeButton : OptionButton

##This is the list of all available preview modes
enum dataPreviewMODES {
	##Displays all information about imported 3D model 
	ALL,
	##Displays only mesh objects ([MeshInstance3D])
	OBJECTS_ONLY,
	##Displays only materials
	MATERIALS_ONLY
}

#this enum should be hidden because it starts with "_"
#and using single "#" is just a comment, not a documentation comment
#so there is no reason for it to be visible in the documentation
#
#But it's an internal list of meta tags that are used recognize is the tree item
# a material representation, mesh object or something else
enum _itemMeta {
	Root,
	MeshObj,
	Mat,
	Other
}

##Stores information in which preview mode this [ModelHierarchyWorkspaceArea]
## is currently working.[br]
##This is the list of all available preview modes: [enum ModelHierarchyWorkspaceArea.dataPreviewMODES][br]
##If you want to change preview mode of [ModelHierarchyWorkspaceArea] 
## just set different number into this variable.[br][br]
## Example:
##[codeblock]
##var area = $Reference/to/ModelHierarchyWorkspaceArea
##area.dataPreviewMode = dataPreviewMODES.MATERIALS_ONLY
##[/codeblock]
var dataPreviewMode : int:
	set(newMode):
		dataPreviewMode = newMode
		refreshDisplay()

func _init()->void:
	name = "ModelHierarchyArea"
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func _enter_tree()->void:
	ServerModelHierarchy._addDisplayWorkspaceArea(self)

func _exit_tree()->void:
	ServerModelHierarchy._removeDisplayWorkspaceArea(self)

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
	dataPreviewModeButton.item_selected.connect(_switchDisplayDataMode)
	
	_treeDisplay.button_clicked.connect(_visibilityButtonPressed)
	_treeDisplay.item_selected.connect(_treeDisplayItemSelected)
	if Alter3DScene.modelRootNode != null:
		refreshDisplay()

func _mouse_entered()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE

func _switchDisplayDataMode(mode : int)->void:
	dataPreviewMode = mode

##Refreshes entire imported 3D model preview [Tree] structure.
## Used when [member ModelHierarchyWorkspaceArea.dataPreviewMode] changes
## or when 3D model is imported 
func refreshDisplay()->void:
	_treeDisplay.clear()
	_objectsLookupTable.clear()
	_visibleStateLookupTable.clear()
	_undefinedMaterialCounter = 0
	_lastButtonID = 0
	_loadTreeDisplayData()

func _loadTreeDisplayData()->void:
	match dataPreviewMode:
		dataPreviewMODES.ALL:
			_loadAllDataDisplay(Alter3DScene.modelRootNode,true)
		dataPreviewMODES.OBJECTS_ONLY:
			_loadAllDataDisplay(Alter3DScene.modelRootNode,false)
		dataPreviewMODES.MATERIALS_ONLY:
			_loadMaterialsDisplay()

func _loadAllDataDisplay(rootNode : Node,includeMaterial : bool = true, iterationParent : TreeItem = null)->void:
	if rootNode is StaticBody3D:
		return
	
	var createdItem : TreeItem
	if iterationParent != null:
		createdItem = _treeDisplay.create_item(iterationParent)
		createdItem.set_text(0,rootNode.name)
	else:
		createdItem = _treeDisplay.create_item()
		createdItem.set_text(0,"Root")
	
	if rootNode is MeshInstance3D:
		createdItem.set_icon(0,_meshIcon)
		createdItem.set_meta("type",_itemMeta.MeshObj)
		
		var objectVisiblityIcon : Texture2D
		if rootNode.visible:
			objectVisiblityIcon = _meshVisibleIcon
		else:
			objectVisiblityIcon = _meshHiddenIcon
		
		createdItem.add_button(1,objectVisiblityIcon,_lastButtonID,false)
		
		_visibleStateLookupTable.merge({_lastButtonID : rootNode.visible})
		_objectsLookupTable.merge({_lastButtonID : rootNode})
		
		_lastButtonID += 1
		
		if includeMaterial:
			for surfID : int in rootNode.mesh.get_surface_count():
				var matItem : TreeItem
				
				var mat : Material
				var matIcon : Texture2D
				
				if rootNode.mesh.surface_get_material(surfID) != null:
					matItem = _treeDisplay.create_item(createdItem)
					mat = rootNode.mesh.surface_get_material(surfID)
					matItem.set_meta("type",_itemMeta.Mat)
				
				if mat.resource_name.begins_with("<"):
					matIcon = _uknownMaterialIcon
				else:
					matIcon = _materialIcon
				
				if mat.resource_name == ServerModelHierarchy.selectedMaterialName:
					matItem.set_custom_color(0,ServerModelHierarchy.selectedMatThemeColor)
				
				matItem.set_text(0,mat.resource_name)
				matItem.set_icon(0,matIcon)
	else:
		createdItem.set_meta("type",_itemMeta.Other)
		if rootNode is Node3D:
			createdItem.set_icon(0,_importedNotMesh)
		if rootNode is Control:
			createdItem.set_icon(0,_importFailIcon)
		if rootNode is Node2D:
			createdItem.set_icon(0,_importFailIcon)
		if rootNode is GPUParticles3D or GPUParticlesAttractor3D or GPUParticlesCollision3D:
			createdItem.set_icon(0,_importFailIcon)
		
		if iterationParent == null:
			createdItem.set_meta("type",_itemMeta.Root)
			createdItem.set_icon(0,_rootIcon)
	for child in rootNode.get_children():
		_loadAllDataDisplay(child,includeMaterial,createdItem)

func _loadMaterialsDisplay()->void:
	var rootItem := _treeDisplay.create_item()
	rootItem.set_meta("type",_itemMeta.Root)
	rootItem.set_text(0,"Materials")
	for mat : Material in Alter3DScene.modelMaterials:
		var materialItem := _treeDisplay.create_item()
		materialItem.set_meta("type",_itemMeta.Mat)
		
		var matIcon : Texture2D
		
		if mat.resource_name.begins_with("<"):
			matIcon = _uknownMaterialIcon
		else:
			matIcon = _materialIcon
		
		if mat.resource_name == ServerModelHierarchy.selectedMaterialName:
			materialItem.set_custom_color(0,ServerModelHierarchy.selectedMatThemeColor)
		
		materialItem.set_text(0,mat.resource_name)
		materialItem.set_icon(0,matIcon)

func _treeDisplayItemSelected()->void:
	var selectedItem := _treeDisplay.get_selected()
	if selectedItem.get_meta("type") == _itemMeta.Mat:
		var selectedText : String = selectedItem.get_text(0)
		for matID in Alter3DScene.modelMaterials.size():
			if Alter3DScene.modelMaterials[matID].resource_name == selectedText:
				ServerModelHierarchy.selectedMaterialIndex = matID
				break
		ServerModelHierarchy.selectedMaterialName = selectedText
		ServerModelHierarchy.refreshSelectedMaterialItems()
		ServerLayersStack._reloadWorkspacesLayers()

##Changes color of the items' texts. Used to refresh text colors
## when any material is selected, to indicate currently selected material that
## will be edited by [LayersWorkspaceArea]
func changeItemTreeColors_init()->void:
	_changeItemTreeColors(_treeDisplay.get_root())

func _changeItemTreeColors(rootItem : TreeItem)->void:
	if rootItem.get_text(0) != ServerModelHierarchy.selectedMaterialName:
		rootItem.clear_custom_color(0)
	else:
		rootItem.set_custom_color(0,ServerModelHierarchy.selectedMatThemeColor)
	for child : TreeItem in rootItem.get_children():
		_changeItemTreeColors(child)


func _visibilityButtonPressed(_item: TreeItem, _column: int, id: int, _mouse_button_index: int)->void:
	var buttonState : bool = !_visibleStateLookupTable[id]
	_visibleStateLookupTable[id] = buttonState
	
	var meshObject : Node = _objectsLookupTable[id]
	meshObject.visible = buttonState
	
	ServerModelHierarchy.refreshDisplayData()
