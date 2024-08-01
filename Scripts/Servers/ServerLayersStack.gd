class_name ServerLayersStack extends RefCounted

##This class stores all the layers for each individual material of imported 3D model[br]
##Also allows to make changes into the layer stacks.

static var _layerWorkspaces : Array[LayersWorkspaceArea]
#warning_ignore is used because Godot mistakes this as an unused variable
#while it's used inside [ModelHierarchyWorkspaceArea] or [LayersWorkspaceArea]
@warning_ignore("unused_private_class_variable")
static var _materialsLoaded : bool = false

##This is a list of layer stacks, each corresponding to each individual imported material.
static var materialsLayers : Array[LayersStack]

##Stores index of currently selected layer in the server stack
static var selectedLayerIndex : int = -5

#used by [Alter3DScene] when loading materials from imported 3D model
static func _appendNewMaterialLayersStack()->void:
	materialsLayers.append(LayersStack.new())

#used to register new workspace so it can be modified by the server
#with static functions
static func _addNewLayerWorkspace(workspace : LayersWorkspaceArea)->void:
	_layerWorkspaces.append(workspace)

#used to unregister workspace that is about to be removed or switched
static func _removeLayerWorkspace(workspace : LayersWorkspaceArea)->void:
	var index := _layerWorkspaces.find(workspace)
	_layerWorkspaces.remove_at(index)

##Use this funtion to add new layer both into the server's stack and to all [LayersWorkspaceArea]s[br]
##by default the material that you will add new layer to is the currently selected one in [ModelHierarchyWorkspaceArea]
##if you want to add new layer into very specific material you can use [param matID] to do that.[br]
##matID must be contained in boundries of [member Alter3DScene.modelMaterials] size
static func addLayer(layerType : LayerData.layerTypes,
					matID : int = ServerModelHierarchy.selectedMaterialIndex,
					visibility : bool = true,
					colors : Dictionary = {},
					title : String = "",
					opacity : float = 1.0,
					mixType : int = 0)->void:
	var layersStack := materialsLayers[matID].layers
	if title.is_empty():
		title = "New Layer nr." + str(layersStack.size()+1)
	var newLayerData := LayerData.new(visibility,colors,title,opacity,mixType,layerType)
	layersStack.append(newLayerData)
	
	if matID != ServerModelHierarchy.selectedMaterialIndex:
		#To prevent adding UI layers when those shouldn't be visible
		#since they are set to different material.
		return
	for workspace : LayersWorkspaceArea in _layerWorkspaces:
		workspace._add_UI_Layer(newLayerData)
	
	mixer.mixInputs(matID)

##Use this function to remove layer both from the server's stack and to all [LayersWorkspaceArea]s[br]
##[param UIindex] is the layer index in UI stack. so index 0 will remove layer that is on top of the stack.
static func removeLayer(UIindex : int)->void:
	var matID : int = ServerModelHierarchy.selectedMaterialIndex
	var layersStack := materialsLayers[matID].layers
	
	#this weird equation inside the brackets is used to
	#convert index from UI control based layer stack
	#into the one that server uses
	layersStack.remove_at(layersStack.size() - UIindex - 1)
	for workspace in _layerWorkspaces:
		workspace._remove_UI_Layer(UIindex)
	
	mixer.mixInputs(matID)

##Use this function to change layer that is in index [param fromIndex] to [param toIndex]
## both in server's layers stack and all [LayersWorkspaceArea]s[br]
##[param fromIndex] and [toIndex] use UI stack order. So setting [param fromIndex] to 0 and [toIndex] to -1
## will move the very top layer in the stack to the very bottom.
static func reorderLayer(fromIndex : int, toIndex : int,)->void:
	#Because backend of handling stacks is inverted to what can be seen visually
	#index 0 is at the bottom of the stack in ServerLayersStack.layerStack
	#where index 0 in get_child() gives layer that is on top of the stack
	#So it requires some math to convert it ;)
	var matID : int = ServerModelHierarchy.selectedMaterialIndex
	var layersStack := materialsLayers[matID].layers
	var stackFromIndex : int = layersStack.size() - fromIndex - 1
	var stackToIndex : int = layersStack.size() - toIndex - 1
	
	var storedLayer : LayerData = layersStack[stackFromIndex]
	layersStack.remove_at(stackFromIndex)
	layersStack.insert(stackToIndex,storedLayer)
	
	for workspace in _layerWorkspaces:
		workspace.refreshLayersOrder(fromIndex, toIndex)
	
	mixer.mixInputs(matID)

##Used to sync layer properties when change is made in the [LayerUI_node][br]
##[param layerID] is the UI layer index of the stack[br]
##[param exclude] is used to exclude certain layers from syncing data.
## Useful for example when layer A wants to sync it's changes to other layers,
## but don't want to sync it's own properties into itself.
static func syncLayerProperties(layerID : int, exclude : LayerUI_node = null)->void:
	for workspace in _layerWorkspaces:
		var layerNode : LayerUI_node = workspace.layersList.get_child(layerID)
		if exclude != null:
			if layerNode == exclude:
				continue
		layerNode.updatePropertiesFromData()

##Cleans all the [LayerUI_node]s from all [LayersWorkspaceArea]s[br]
##[br][color=#edcb6d][b]IMPORTANT[/b][br][/color]
##this doesn't clean layers from the server's  [member ServerLayersStack.materialsLayers]
##If you need to you can loop through all it's items and clear those.
static func cleanWorkspacesLayers()->void:
	for workspace in _layerWorkspaces:
		workspace._remove_all_UI_Layers()

#Used by [ModelHierarchyWorkspaceArea] when material is reselected 
static func _reloadWorkspacesLayers()->void:
	for workspace in _layerWorkspaces:
		workspace._reload_UI_Layers()

##Available modes of layer stack:
enum layerChannels {
	##Shows how layers contribute to color of the material
	Albedo,
	##Shows how layers contribute to roughness of the material
	Roughness,
	##Shows how layers contribute to metallnes of the material
	Metalness,
	##Shows how layers contribute to normal of the material
	Normal,
}

##Class that stores all the layer datas for single material
class LayersStack:
	##This variable stores actuall information about layers order and properties.
	##Note that the order of layers visible in [LayerWorkspaceArea] is reversed
	##order of this variable. So if you want to get access layer that is at the top
	##of the stack you should use index [param -1] second from top [param -2] and so on.
	##Layer at the bottom of the "Visual" stack is at index 0
	var layers : Array[LayerData]
