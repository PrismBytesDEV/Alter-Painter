class_name LayersWorkspaceArea extends WorkspaceArea

var selectedLayer : LayerUI_node

var layerTypeSwitch : OptionButton
var addNewLayerButton : MenuButton
var removeLayerButton : Button

@onready var newLayerButtonIcon : Texture2D = preload("res://textures/icons/ToolAddNode.svg")
@onready var RemoveLayerButtonIcon : Texture2D = preload("res://textures/icons/Remove.svg")

@onready var showLayerButtonIcon : Texture2D = preload("res://textures/icons/GuiVisibilityVisible.svg")
@onready var hideLayerButtonIcon : Texture2D = preload("res://textures/icons/GuiVisibilityHidden.svg")

@onready var fillLayerUI : PackedScene = preload("res://Scenes/layer_ui_fill.tscn") 
@onready var layersList : LayersGapRenderer = %LayerList
@onready var layersScroll : ScrollContainer = %listScroll

var layerSize : Vector2

static var canDropLayer : bool = true

static var draggingAnyLayer : bool = false

var layerStackPreviewTypeMode : int

func _init()->void:
	name = "LayersWorkspaceArea"
	mouse_entered.connect(_mouse_entered_LayersArea)
	mouse_exited.connect(_mouse_exited_LayersArea)

func _enter_tree()->void:
	ServerLayersStack.addNewLayerWorkspace(self)

func _exit_tree()->void:
	ServerLayersStack.removeLayerWorkspace(self)

func _ready()->void:
	setupWorkspaceArea()
	#Loads all the layers from the server if any exist
	_reload_UI_Layers()
	
	layerTypeSwitch = OptionButton.new()
	layerTypeSwitch.tooltip_text = "Switch layer type"
	layerTypeSwitch.fit_to_longest_item = false
	layerTypeSwitch.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN + SIZE_EXPAND
	for type : int in ServerLayersStack.layerTypes.size():
		layerTypeSwitch.add_item(str(ServerLayersStack.layerTypes.keys()[type]))
	layerTypeSwitch.selected = 0
	areaOptionsContainer.add_child(layerTypeSwitch)
	layerTypeSwitch.item_selected.connect(switchLayerStackType)
	
	addNewLayerButton = MenuButton.new()
	addNewLayerButton.tooltip_text = "Add layer"
	addNewLayerButton.icon = newLayerButtonIcon
	areaOptionsContainer.add_child(addNewLayerButton)
	
	var addLayerButtonPopup := addNewLayerButton.get_popup()
	addLayerButtonPopup.index_pressed.connect(_addNewLayer)
	addLayerButtonPopup.add_item("new Fill Layer")
	addLayerButtonPopup.add_item("new Paint Layer")
	
	removeLayerButton = Button.new()
	removeLayerButton.tooltip_text = "Removes last selected layer"
	removeLayerButton.pressed.connect(_removeLayer)
	removeLayerButton.icon = RemoveLayerButtonIcon
	removeLayerButton.flat = true
	areaOptionsContainer.add_child(removeLayerButton)
	
	layersList.selfWorkspaceArea = self

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
##See [member ServerLayersStack.layerTypes] for list of all available [param index]es
func switchLayerStackType(index : int)->void:
	print("Layer stack switched to: ",ServerLayersStack.layerTypes.keys()[index])
	layerStackPreviewTypeMode = index

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
##[param id] tells whenewer you are adding a Fill Layer or a Paint Layer
## 0 = Fill Layer
## 1 = Paint Layer
func _addNewLayer(id : int)->void:
	if id == 1:
		printerr("Paint layers aren't implemented yet!")
		return
	ServerLayersStack.addLayer()

#DO NOT USE THIS TO ADD LAYER TO THE STACK
#Instead use method _addNewLayer(id : int) from this class
#or method addLayer() from ServerLayersStack
#This method's only purpouse is to add physical Control node that
#represent new added layer. So if you call this method it will only
#add layer to stack visually on the LayersWorkspaceArea it was used, but not on others.
func _add_UI_Layer(data : FillLayerData)->void:
	var newLayer : LayerUI_node = fillLayerUI.instantiate()
	newLayer.layerSelected.connect(_layerSelected)
	newLayer.layerData = data
	newLayer.layersWorkspaceParent = self
	layersList.add_child(newLayer)
	layerSize = newLayer.size
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
	if !ServerLayersStack.materialsLoaded:
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
	var scrollRect := layersScroll.get_global_rect()
	var upper := scrollRect.position.y + (scrollRect.size.y * 0.2)
	var lower := scrollRect.position.y + (scrollRect.size.y * (1.0 - 0.2))
	if upper > mousePos.y:
		var factor : float = (upper - mousePos.y) / (upper - scrollRect.position.y)
		@warning_ignore("narrowing_conversion")
		layersScroll.scroll_vertical -= 1500.0 * factor * delta
	elif lower < mousePos.y:
		var factor := (mousePos.y - lower) / (scrollRect.end.y - lower)
		@warning_ignore("narrowing_conversion")
		layersScroll.scroll_vertical += 1500.0 * factor * delta

#FIXME Fix the bug that makes gap line render incorrectly when there is too much layers??
#also requires more investigation.

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

func dropGapIndex()->int:
	var mousePos : Vector2 = get_viewport().get_mouse_position() - layersList.global_position
	var layerSpacing : float = layerSize.y + layersList.get_theme_constant("separation")
	@warning_ignore("narrowing_conversion")
	var gapYMod : int = (mousePos.y + (0.5 * layerSpacing)) / layerSpacing
	gapYMod = min(gapYMod * layerSpacing,layersList.get_child_count() * layerSpacing)
	@warning_ignore("narrowing_conversion")
	return gapYMod / layerSpacing
