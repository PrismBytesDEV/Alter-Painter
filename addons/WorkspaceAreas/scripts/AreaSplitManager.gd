class_name AreaSplitManager extends Control

##Class that does all the heavy lifting for splitting, merging and swaping areas.[br]
##It has the code to render the "split line" and it splits Workspaces depending on what user
##selected from the popupMenu.

##Stores information about are workspace areas are about to be split
##or not.
static var CurrentSplitMode : SplitMode

var _mousePos : Vector2
var _areaSplitOptionsPopup : PopupMenu

static var _selfStaticReference : AreaSplitManager

##Available list of splits: 
enum SplitMode{
	##When no split mode is currently used
	None,
	##When we split workspaces into two with a Vertical Line,
	##so they are horizontally set beside each other.
	VSplit,
	##When we split workspaces into two with a Horizontal Line,
	##so they are vertically set beside each other.
	HSplit
}

##Available options to perform on [WorkspaceArea](s)
enum popupOptions{
	##Splits [WorkspaceArea] into two with a vertical line
	VerticalSplit,
	##Splits [WorkspaceArea] into two with a horizontal line
	HorizontalSplit,
	##Merges two [WorkspaceArea]s into one
	JoinAreas,
	##Swaps two [WorkspaceArea]s 
	SwapAreas
}

func _init()->void:
	_selfStaticReference = self
	
	self.set_anchor_and_offset(SIDE_LEFT,0,0)
	self.set_anchor_and_offset(SIDE_TOP,0,0)
	self.set_anchor_and_offset(SIDE_RIGHT,1,0)
	self.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	self.grow_horizontal = GROW_DIRECTION_BOTH
	self.grow_vertical = GROW_DIRECTION_BOTH
	self.mouse_filter = MOUSE_FILTER_IGNORE
	
	var horizontalIcon : Texture2D = load("res://addons/WorkspaceAreas/icons/HorizontalAreaSplitIcon.png")
	var verticalIcon : Texture2D = load("res://addons/WorkspaceAreas/icons/VerticalAreaSplitIcon.png")
	
	_areaSplitOptionsPopup = PopupMenu.new()
	_areaSplitOptionsPopup.add_item("Area Options",5)
	_areaSplitOptionsPopup.set_item_as_separator(0,true)
	_areaSplitOptionsPopup.add_item("",5)
	_areaSplitOptionsPopup.set_item_as_separator(1,true)
	_areaSplitOptionsPopup.add_icon_item(verticalIcon,"Vertical Split",0)
	_areaSplitOptionsPopup.add_icon_item(horizontalIcon,"Horizontal Split",1)
	_areaSplitOptionsPopup.add_item("",5)
	_areaSplitOptionsPopup.set_item_as_separator(4,true)
	_areaSplitOptionsPopup.add_item("Join Areas",2)
	_areaSplitOptionsPopup.add_item("Swap Areas",3)
	AreaSplitContainer._dockOptionsPopup = _areaSplitOptionsPopup

func _ready()->void:
	get_parent().move_child.call_deferred(self,-1)
	get_tree().get_current_scene().add_child.call_deferred(_areaSplitOptionsPopup)
	_areaSplitOptionsPopup.hide()
	
	_areaSplitOptionsPopup.id_pressed.connect(_receivePopupInfo)
	CurrentSplitMode = SplitMode.None

func _input(event : InputEvent)->void:
	if event is InputEventMouseMotion:
		_mousePos = event.position
		if CurrentSplitMode != SplitMode.None:
			self.queue_redraw()
	if event is InputEventMouseButton:
		if event.pressed: 
			if event.button_index == 1:
				if CurrentSplitMode != SplitMode.None:
					AreaSplitManager.splitArea(WorkspaceArea.CurrentMouseHoverArea,CurrentSplitMode,_mousePos)
					CurrentSplitMode = SplitMode.None
					self.queue_redraw()
			if event.button_index == 2:
				if CurrentSplitMode != SplitMode.None:
					cancelOperation()

func _draw():
	var area := WorkspaceArea.CurrentMouseHoverArea
	if area == null:
		return
	
	var firstPoint : Vector2
	var secondPoint : Vector2
	
	if CurrentSplitMode == SplitMode.VSplit:
		var _upYPos : float = area.global_position.y
		var _downYPos : float = area.global_position.y + area.size.y
		firstPoint = Vector2(_mousePos.x,_upYPos)
		secondPoint = Vector2(_mousePos.x,_downYPos)
	elif CurrentSplitMode == SplitMode.HSplit:
		var _leftXPos : float = area.global_position.x
		var _rightXPos : float = area.global_position.x + area.size.x
		firstPoint = Vector2(_leftXPos,_mousePos.y)
		secondPoint = Vector2(_rightXPos,_mousePos.y)
	
	draw_line(firstPoint,secondPoint,Color.WHITE,1)

##Allows to split the specified [WorkspaceArea] into two, with a parameter [param area] as [WorkspaceArea] we want to split.[br]
##with a line specified with [enum AreaSplitManager.SplitMode].[br]
##And also requires mouse's position as a third parameter
static func splitArea(area : WorkspaceArea, splitDirection : SplitMode,mousePos : Vector2)->void:
	if splitDirection == SplitMode.None:
		printerr("Can't split WorkspaceArea without the direction specified!")
		return
	var areaParent : Node = area.get_parent()
	var splitNode := AreaSplitContainer.new()
	splitNode.mouse_filter = Control.MOUSE_FILTER_PASS
	# != is use because I made a mistake and I thought splitting Vertically means
	# splitting children so the split handle is Vertical... But it's the over way..
	splitNode.vertical = splitDirection != SplitMode.VSplit
	areaParent.add_child(splitNode)
	var currentAreaIndex : int = area.get_index()
	areaParent.move_child(splitNode,currentAreaIndex)
	area.reparent(splitNode)
	var secondNewArea := area.duplicate()
	#FIXME AreaSplitManager.gd:69 @ splitArea(): Node not found: "areaVbox" (relative to "Preview3DArea")
	secondNewArea.hide()
	splitNode.add_child(secondNewArea)
	if splitDirection == SplitMode.VSplit:
		splitNode.split_offset = int(mousePos.x) 
	if splitDirection == SplitMode.HSplit:
		splitNode.split_offset = int(mousePos.y) 
	area.show()
	secondNewArea.show()

##When user selects an option to split, merge, swap areas, and user cancels that, this function is called.
##You can use it if you want to cancel that option by code,
## although I don't see practicall usage for that outside of that addon's API
static func cancelOperation()->void:
	CurrentSplitMode = SplitMode.None
	_selfStaticReference.queue_redraw()

func _receivePopupInfo(index : int)->void:
	match index:
		popupOptions.VerticalSplit:
			CurrentSplitMode = SplitMode.VSplit
		popupOptions.HorizontalSplit:
			CurrentSplitMode = SplitMode.HSplit
		popupOptions.JoinAreas:
			CurrentSplitMode = SplitMode.None
		popupOptions.SwapAreas:
			CurrentSplitMode = SplitMode.None
