class_name LayersWorkspaceArea extends WorkspaceArea

##This [WorkspaceArea] allows user to easly add, remove, edit layers.

##Holds reference to the currently selected Layer UI node
var selectedLayer : LayerUI_node:
	set(newLayer):
		var matID : int = ServerModelHierarchy.selectedMaterialIndex
		var layersStack := ServerLayersStack.materialsLayers[matID].layers
		ServerLayersStack.selectedLayerIndex = - 1 - newLayer.get_index()
		selectedLayer = newLayer

var _layerTypeSwitch : OptionButton
var _addNewLayerButton : MenuButton
var _removeLayerButton : Button

@onready var _newLayerButtonIcon : Texture2D = preload("res://textures/icons/ToolAddNode.svg")
@onready var _RemoveLayerButtonIcon : Texture2D = preload("res://textures/icons/Remove.svg")

@onready var _fillLayerUI : PackedScene = preload("res://Scenes/layer_ui.tscn")
 
##Holds reference to the parent node of all layer UI nodes
## it also [LayersGapRenderer] that draws drop line when user is dragging any layer
@onready var layersList : LayersGapRenderer = %LayerList
@onready var _layersScroll : ScrollContainer = %listScroll

##Stores information of size of the layer
var layerSize : Vector2

##Defines if dragged layer can be dropped
static var canDropLayer : bool = true
##Stores information about is any layer currently dragged by the user
static var draggingAnyLayer : bool = false

##Stores information about the preview mode of this [LayersWorkspaceArea]
## to see more information about available modes look into [enum ServerLayersStack.layerChannels]
var layerStackPreviewTypeMode : int

func _init()->void:
	name = "LayersWorkspaceArea"
	mouse_entered.connect(_mouse_entered_LayersArea)
	mouse_exited.connect(_mouse_exited_LayersArea)

func _enter_tree()->void:
	ServerLayersStack._addNewLayerWorkspace(self)

func _exit_tree()->void:
	ServerLayersStack._removeLayerWorkspace(self)

func _ready()->void:
	setupWorkspaceArea()
	#Loads all the layers from the server if any exist
	_reload_UI_Layers()
	
	_layerTypeSwitch = OptionButton.new()
	_layerTypeSwitch.tooltip_text = "Switch layer type"
	_layerTypeSwitch.fit_to_longest_item = false
	_layerTypeSwitch.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN + SIZE_EXPAND
	for type : int in ServerLayersStack.layerChannels.size():
		_layerTypeSwitch.add_item(str(ServerLayersStack.layerChannels.keys()[type]))
	_layerTypeSwitch.selected = 0
	areaOptionsContainer.add_child(_layerTypeSwitch)
	_layerTypeSwitch.item_selected.connect(switchLayerStackType)
	
	_addNewLayerButton = MenuButton.new()
	_addNewLayerButton.tooltip_text = "Add layer"
	_addNewLayerButton.icon = _newLayerButtonIcon
	areaOptionsContainer.add_child(_addNewLayerButton)
	
	var addLayerButtonPopup := _addNewLayerButton.get_popup()
	addLayerButtonPopup.index_pressed.connect(addNewLayer)
	for type : int in LayerData.layerTypes.size():
		addLayerButtonPopup.add_item("New " + str(LayerData.layerTypes.keys()[type]) + " layer")
	
	_removeLayerButton = Button.new()
	_removeLayerButton.tooltip_text = "Removes last selected layer"
	_removeLayerButton.pressed.connect(_removeLayer)
	_removeLayerButton.icon = _RemoveLayerButtonIcon
	_removeLayerButton.flat = true
	areaOptionsContainer.add_child(_removeLayerButton)
	
	layersList._selfWorkspaceArea = self

func _process(delta : float)->void:
	if draggingAnyLayer and WorkspaceArea.CurrentMouseHoverArea == self:
		_handleAutoScrollWhenDragging(delta)

func _mouse_entered_LayersArea()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited_LayersArea()->void:
	CurrentMouseHoverArea = null
	if draggingAnyLayer:
		layersList.queue_redraw()
	if debugCurrentHoverArea:
		modulate = Color.WHITE

##Allows used [WorkspaceArea] switch layers stack to different mode.[br]
##For example from Albedo to Rougness or NormalMap.[br]
##[param index] is used to specify to which mode you are switching the [WorkspaceArea][br]
##See [member ServerLayersStack.layerChannels] for list of all available [param index]es
func switchLayerStackType(index : int)->void:
	layerStackPreviewTypeMode = index
	for layer : LayerUI_node in layersList.get_children():
		layer.updatePropertiesFromData()

##Called when [ServerLayersStack] changes order of it's stack.
## This function is used to change the order of the layer in UI stack.
## [param fromIndex] and [param toIndex] are UI indexes
## meaning that index 0 is the top layer and -1 is the bottom layer.
## This function doesn't change layer's order on serverSide of things.
## To change layer both serverside and visually in the UI use [method ServerLayersStack.reorderLayer()]
func refreshLayersOrder(fromIndex : int, toIndex : int)->void:
	var layer : LayerUI_node = layersList.get_child(fromIndex)
	layersList.move_child(layer,toIndex)
	
	var matID : int = ServerModelHierarchy.selectedMaterialIndex
	var layersStack := ServerLayersStack.materialsLayers[matID].layers
	
	#After fillLayerData is reindexed in the server's stack
	#It needs to be updated to work correctly on both server side
	#and the UI side
	layer.layerData = layersStack[-toIndex-1]

##Adds new layer to the stack on all [LayersWorkspaceArea][br]
##[param id] tells whenewer you are adding a Fill Layer or a Paint Layer or different type of layer.
##See [enum LayerData.layerTypes] for all available layer types.
func addNewLayer(id : LayerData.layerTypes)->void:
	match id:
		LayerData.layerTypes.fill:
			ServerLayersStack.addLayer(LayerData.layerTypes.fill)
		LayerData.layerTypes.paint:
			ServerLayersStack.addLayer(LayerData.layerTypes.paint)

#DO NOT USE THIS TO ADD LAYER TO THE STACK
#Instead use method _addNewLayer(id : int) from this class
#or method addLayer() from ServerLayersStack
#This method's only purpouse is to add physical Control node that
#represent new added layer. So if you call this method it will only
#add layer to stack visually on the LayersWorkspaceArea it was used, but not on others.
func _add_UI_Layer(data : LayerData)->void:
	var newLayer : LayerUI_node = _fillLayerUI.instantiate()
	newLayer.layerSelected.connect(_layerSelected)
	newLayer.layerData = data
	selectedLayer = newLayer
	newLayer.layersWorkspaceParent = self
	layersList.add_child(newLayer)
	layerSize = layersList.get_child(0).size
	layersList.layerSize = layerSize
	layersList.move_child(newLayer,0)

func _removeLayer()->void:
	if selectedLayer != null:
		var removeIndex : int = selectedLayer.get_index()
		ServerLayersStack.removeLayer(removeIndex)

func _remove_UI_Layer(atIndex : int)->void:
	#.free() is used instead of queue_free()
	#because with queue_free() when for example we have 3 layers
	#and remove one with this method, both workspace and layerNodes still
	#are still thinking that there are 3 layers. Maybe because of the queue thing
	#The layer still exist somehow even though it shouldn't??!
	#If someone will find a fix for that with that uses queue_free()
	#I'll be thankful ;D
	
	#Outdated ^^^
	#But I decided to leave it because maybe something will broke again ;d
	
	if layersList.get_child(atIndex) != null:
		layersList.get_child(atIndex).queue_free()

func _remove_all_UI_Layers()->void:
	for layer in layersList.get_children():
		layer.queue_free()

func _reload_UI_Layers()->void:
	if !ServerLayersStack._materialsLoaded:
		return
	
	for layerID : int in layersList.get_child_count():
		_remove_UI_Layer(layerID)
	
	var matID : int = ServerModelHierarchy.selectedMaterialIndex
	var layersStack := ServerLayersStack.materialsLayers[matID].layers
	
	for layerData in layersStack:
		_add_UI_Layer(layerData)

func _layerSelected(layer : LayerUI_node)->void:
	selectedLayer = layer
	

func _handleAutoScrollWhenDragging(delta : float)->void:
	var mousePos : Vector2 = get_global_mouse_position()
	var scrollRect := _layersScroll.get_global_rect()
	var upper := scrollRect.position.y + (scrollRect.size.y * 0.2)
	var lower := scrollRect.position.y + (scrollRect.size.y * (1.0 - 0.2))
	if upper > mousePos.y:
		var factor : float = (upper - mousePos.y) / (upper - scrollRect.position.y)
		@warning_ignore("narrowing_conversion")
		_layersScroll.scroll_vertical -= 1500.0 * factor * delta
	elif lower < mousePos.y:
		var factor := (mousePos.y - lower) / (scrollRect.end.y - lower)
		@warning_ignore("narrowing_conversion")
		_layersScroll.scroll_vertical += 1500.0 * factor * delta

func _can_drop_data(_at_position : Vector2, data : Variant)->bool:
	#Called while still dragging layer
	var isMouseHoveringCorrectArea : bool = WorkspaceArea.CurrentMouseHoverArea is LayersWorkspaceArea
	
	var layerNode : LayerUI_node = data
	var layerOG_Index : int = layerNode.get_index()
	
	var drop_gap_index : int = dropGapIndex()
	
	var indexChanged : bool = !(drop_gap_index == layerOG_Index or drop_gap_index == (layerOG_Index + 1))
	canDropLayer = isMouseHoveringCorrectArea and indexChanged
	layersList.queue_redraw()	
	return canDropLayer

func _drop_data(_at_position : Vector2, data : Variant)->void:
	#Called when dropping layer
	var layerNode : LayerUI_node = data
	
	var layerUI_ogIndex : int = layerNode.get_index()
	var layerUI_dropIndex : int = dropGapIndex()
	
	if layerUI_ogIndex < layerUI_dropIndex:
		layerUI_dropIndex -= 1
	
	ServerLayersStack.reorderLayer(layerUI_ogIndex,layerUI_dropIndex)
	
	draggingAnyLayer = false

##Retrieves UI index where dragged layer could be moved if it were dropped now. 
func dropGapIndex()->int:
	var mousePos : Vector2 = get_viewport().get_mouse_position() - layersList.global_position
	var layerSpacing : float = layerSize.y + layersList.get_theme_constant("separation")
	@warning_ignore("narrowing_conversion")
	var gapYMod : int = (mousePos.y + (0.5 * layerSpacing)) / layerSpacing
	gapYMod = min(gapYMod * layerSpacing,layersList.get_child_count() * layerSpacing)
	@warning_ignore("narrowing_conversion")
	return gapYMod / layerSpacing
