extends Node

enum SplitMode{
	None,VSplit,HSplit
}
static var CurrentSplitMode : SplitMode

var _mousePos : Vector2
@onready var splitLine : Line2D = $"SplitLine"
@onready var _dockOptionsPopup : PopupMenu = %DockOptionsPopup

func _ready()->void:
	_dockOptionsPopup.id_pressed.connect(_receivePopupInfo)
	splitLine.hide()
	CurrentSplitMode = SplitMode.None

func _process(_delta : float)->void:
	var area := WorkspaceArea.CurrentMouseHoverArea
	
	if CurrentSplitMode != SplitMode.None:
		splitLine.visible = area != null
	if area == null:
		return
	if CurrentSplitMode == SplitMode.VSplit:
		var _upYPos : float = area.global_position.y
		var _downYPos : float = area.global_position.y + area.size.y
		splitLine.set_point_position(0,Vector2(_mousePos.x,_upYPos))
		splitLine.set_point_position(1,Vector2(_mousePos.x,_downYPos))
	elif CurrentSplitMode == SplitMode.HSplit:
		var _leftXPos : float = area.global_position.x
		var _rightXPos : float = area.global_position.x + area.size.x
		splitLine.set_point_position(0,Vector2(_leftXPos,_mousePos.y))
		splitLine.set_point_position(1,Vector2(_rightXPos,_mousePos.y))

func _input(event : InputEvent)->void:
	if event is InputEventMouseMotion:
		_mousePos = event.position
	if event is InputEventMouseButton:
		if event.pressed: 
			if event.button_index == 1:
				if CurrentSplitMode != SplitMode.None:
					splitArea(WorkspaceArea.CurrentMouseHoverArea,CurrentSplitMode,_mousePos)
					CurrentSplitMode = SplitMode.None
					splitLine.hide()
			if event.button_index == 2:
				if CurrentSplitMode != SplitMode.None:
					cancelSplit()

func splitArea(area : WorkspaceArea, splitDirection : SplitMode,mousePos : Vector2)->void:
	var areaParent : Node = area.get_parent()
	var splitNode := AreaSplitContainer.new()
	# != is use because I made a mistake and I thought splitting Vertically means
	# splitting child so the split handle is Vertical... But it's the over way..
	splitNode.mouse_filter = Control.MOUSE_FILTER_PASS
	splitNode.vertical = splitDirection != SplitMode.VSplit
	areaParent.add_child(splitNode)
	var currentAreaIndex : int = area.get_index()
	area.hide()
	areaParent.move_child(splitNode,currentAreaIndex)
	area.reparent(splitNode)
	var secondNewArea := area.duplicate()
	secondNewArea.hide()
	splitNode.add_child(secondNewArea)
	if splitDirection == SplitMode.VSplit:
		splitNode.split_offset = int(mousePos.x) 
	if splitDirection == SplitMode.HSplit:
		splitNode.split_offset = int(mousePos.y) 
	area.show()
	secondNewArea.show()

func cancelSplit()->void:
	CurrentSplitMode = SplitMode.None
	splitLine.hide()

func _receivePopupInfo(index : int)->void:
	match index:
		0:# Vertical Split
			CurrentSplitMode = SplitMode.VSplit
			splitLine.show()
		1:# Horizontal Split
			CurrentSplitMode = SplitMode.HSplit
			splitLine.show()
		2:# Join Areas
			CurrentSplitMode = SplitMode.None
			splitLine.hide()
		3:# Swap Areas
			CurrentSplitMode = SplitMode.None
			splitLine.hide()
