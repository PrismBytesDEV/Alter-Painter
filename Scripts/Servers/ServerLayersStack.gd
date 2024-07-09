extends RefCounted
class_name ServerLayersStack

static var _layerWorkspaces : Array[LayersWorkspaceArea]

##This variable stores actuall information about layers order and properties.
##Note that the order of layers visible in [LayerWorkspaceArea] is reversed
##order of this variable. So if you want to get access layer that is at the top
##of the stack you should use index [param -1] second from top [param -2] and so on.
##Layer at the bottom of the "Visual" stack is at index 0
static var layersStack : Array[FillLayerData]

static func addNewLayerWorkspace(workspace : LayersWorkspaceArea)->void:
	_layerWorkspaces.append(workspace)

static func removeLayerWorkspace(workspace : LayersWorkspaceArea)->void:
	var index := _layerWorkspaces.find(workspace)
	_layerWorkspaces.remove_at(index)

static func addLayer()->void:
	var newLayerData := FillLayerData.new(true,[],"New Layer nr." + str(layersStack.size()+1),1.0,0)
	layersStack.append(newLayerData)
	for workspace in _layerWorkspaces:
		workspace._add_UI_Layer(newLayerData)

static func removeLayer(index : int)->void:
	layersStack.remove_at(index)
	for workspace in _layerWorkspaces:
		workspace._remove_UI_Layer(index)

static func reorderLayer(fromIndex : int, toIndex : int,)->void:
	#Because backend of handling stacks is inverted to what can be seen visually
	#index 0 is at the bottom of the stack in ServerLayersStack.layerStack
	#where index 0 in get_child() gives layer that is on top of the stack
	#So it requires some math to convert it ;)
	
	var stackFromIndex : int = layersStack.size() - fromIndex - 1
	var stackToIndex : int = layersStack.size() - toIndex - 1
	
	var storedLayer : FillLayerData = layersStack[stackFromIndex]
	layersStack.remove_at(stackFromIndex)
	layersStack.insert(stackToIndex,storedLayer)
	
	for workspace in _layerWorkspaces:
		workspace.refreshLayersOrder(fromIndex, toIndex)

static func syncLayerProperties(layerID : int, exclude : LayerUI_node = null)->void:
	for workspace in _layerWorkspaces:
		var layerNode : LayerUI_node = workspace.layersList.get_child(layerID)
		if exclude != null:
			if layerNode == exclude:
				continue
		layerNode.updatePropertiesFromData()

##Available modes of layer stack:
enum layerTypes {
	##Shows how layers contribute to color of the material
	Albedo,
	##Shows how layers contribute to roughness of the material
	Roughness,
	##Shows how layers contribute to metallnes of the material
	Metalness,
	##Shows how layers contribute to normal map of the material
	Normal
}
