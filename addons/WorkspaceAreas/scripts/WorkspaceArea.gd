class_name WorkspaceArea extends Control

##@experimental
##This a base class for all custom WorkspaceAreas.[br]
##It includes all the API to make your life easier
##in making your own custom WorkspaceArea.
##
##@tutorial(documentation website required!):		https://c.tenor.com/HPmen7OWY08AAAAd/tenor.gif

##Contains the workspace that mouse is currently hovering over
static var CurrentMouseHoverArea : WorkspaceArea

##Made for debug purposes to show active workspaces tha mouse is hovering over
static var debugCurrentHoverArea : bool = false

##This is horizontal options container. That is displayed in the top side of the [WorkspaceArea]
##You can add you own [Button]s and other Control nodes so you can customize your custom [WorkspaceArea]
var areaOptionsContainer : HBoxContainer
##The panel that is the [Control] parent of all the columns and buttons to switch [WorkspaceArea]
var workspaceAreaSelectorPanel : Panel

##Defines the Y size of [member WorkspaceArea.workspaceAreaSelectorPanel]
static var areaSelectorPanelHeight : int = 256

##Set's color of this WorkspaceArea's [member WorkspaceArea.areaOptionsContainer]
@export var areaOptionsPanelColor := Color("272727")
##Set's custom icon for WorkspaceArea, so you can customize your own custom Workspaces.[br]
##[color=#edcb6d][b]IMPORTANT[/b][br][/color]
##Changes aren't applied at runtime!
@export var workspaceAreaIcon : Texture2D = null
##@experimental
##When [param true] a small [Control] node is added with a height of[br]
##[member WorkspaceArea.controlPanelAndContentSeperatorHeight]
##It needs to be fixed since when it's added and WorkspaceArea reach it's
##smallest possible size the switchAreaButton won't be fully visible because of this separator
##[color=#edcb6d][b]IMPORTANT[/b][br][/color]
##When it's set to true the separator won't be created, so don't think it always created but
##it's visibility is set to [param false], because that's not the case.
@export var addControlPanelAndContentSeparator : bool = false
##This defines separation height between [member WorkspaceArea.areaOptionsContainer] and WorkspaceArea's main content
@export var controlPanelAndContentSeperatorHeight : int = 3

var _areaVbox : VBoxContainer
var _areaContent : Control

##This property tells code that this workspaceArea is about to be switched
##to different area. Useful when your custom workspace needs to perform some code
##before before doconstructor.
##Especially if custom workspace area include a funtion that is connected to
##child_order_changed() signal or similar to that.
signal isAboutSwitch

func _init()->void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func _ready()->void:
	setupWorkspaceArea()
	#debugCurrentHoverArea = true

func _showAreaSelectorPanel()->void:
	workspaceAreaSelectorPanel.show()

func _hideAreaSelectorPanel()->void:
	workspaceAreaSelectorPanel.hide()

##Essential method that is required for WorkspaceArea
##to load it's options pale and setup the whole thing.
##Run it at the begging of [member Node._ready()] function:
##[codeblock]
##func _ready():
##		setupWorkspaceArea()
##		[the rest of code...]
##[/codeblock]
func setupWorkspaceArea()->void:
	custom_minimum_size = Vector2i(27,24)
	
	#This check is require for workspaceArea to be duplicated correctly
	if get_child_count() > 1:
		_areaVbox = get_child(0)
		areaOptionsContainer = _areaVbox.get_child(0).get_child(0).get_child(0).get_child(1).get_child(0)
		workspaceAreaSelectorPanel = get_child(-2)
		get_child(-1).queue_free()
		return
	
	if get_child_count() > 0:
		_areaContent = get_child(0)
	
	_areaVbox = VBoxContainer.new()
	_areaVbox.name = "_areaVbox"
	add_child(_areaVbox)
	_areaVbox.set_owner(self)
	move_child(_areaVbox,0)
	_areaVbox.set_anchor_and_offset(SIDE_LEFT,0,0)
	_areaVbox.set_anchor_and_offset(SIDE_TOP,0,0)
	_areaVbox.set_anchor_and_offset(SIDE_RIGHT,1,0)
	_areaVbox.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	_areaVbox.grow_horizontal = GROW_DIRECTION_BOTH
	_areaVbox.grow_vertical = GROW_DIRECTION_BOTH
	_areaVbox.mouse_filter = MOUSE_FILTER_PASS
	_areaVbox.add_theme_constant_override("separation",0)
	
	refreshWorkspaceAreaSelectorPanel()
	
	var areaControlPanel := Panel.new()
	areaControlPanel.name = "areaControlPanel"
	_areaVbox.add_child(areaControlPanel)
	areaControlPanel.set_owner(_areaVbox)
	areaControlPanel.custom_minimum_size = self.custom_minimum_size
	areaControlPanel.size_flags_horizontal = SIZE_FILL
	areaControlPanel.size_flags_vertical = SIZE_FILL
	areaControlPanel.mouse_filter = MOUSE_FILTER_STOP
	
	var areaControlPanelStylebox := StyleBoxFlat.new()
	areaControlPanelStylebox.bg_color = areaOptionsPanelColor
	areaControlPanel.add_theme_stylebox_override("panel",areaControlPanelStylebox)
	
	var areaPanelMargin := MarginContainer.new()
	areaPanelMargin.name = "areaPanelMargin"
	areaControlPanel.add_child(areaPanelMargin)
	areaPanelMargin.set_owner(areaControlPanel)
	areaPanelMargin.size = areaControlPanel.size
	areaPanelMargin.size_flags_horizontal = SIZE_EXPAND_FILL
	areaPanelMargin.size_flags_vertical = SIZE_EXPAND_FILL
	areaPanelMargin.set_anchor_and_offset(SIDE_LEFT,0,0)
	areaPanelMargin.set_anchor_and_offset(SIDE_TOP,0,0)
	areaPanelMargin.set_anchor_and_offset(SIDE_RIGHT,1,0)
	areaPanelMargin.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	areaPanelMargin.grow_horizontal = GROW_DIRECTION_BOTH
	areaPanelMargin.grow_vertical = GROW_DIRECTION_BOTH
	areaPanelMargin.add_theme_constant_override("margin_left",16)
	areaPanelMargin.add_theme_constant_override("margin_right",10)
	areaPanelMargin.mouse_filter = MOUSE_FILTER_PASS
	
	var areaHbox := HBoxContainer.new()
	areaHbox.name = "Hbox"
	areaHbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	areaPanelMargin.add_child(areaHbox)
	areaHbox.set_owner(areaPanelMargin)
	areaHbox.size_flags_horizontal = SIZE_EXPAND_FILL
	areaHbox.size_flags_vertical = SIZE_FILL
	areaHbox.mouse_filter = MOUSE_FILTER_PASS
	
	var areaSwitchButton := Button.new()
	areaHbox.add_child(areaSwitchButton)
	areaSwitchButton.set_owner(areaHbox)
	if workspaceAreaIcon != null:
		areaSwitchButton.icon = workspaceAreaIcon
	else:
		printerr("Custom WorkspaceArea icon not set. Cannot initialize WorkspaceArea with custom icon!")
	areaSwitchButton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	areaSwitchButton.size_flags_horizontal = SIZE_SHRINK_CENTER
	areaSwitchButton.size_flags_vertical = SIZE_FILL
	areaSwitchButton.mouse_filter = MOUSE_FILTER_STOP
	areaSwitchButton.pressed.connect(_showAreaSelectorPanel)
	
	var areaOptionsScroll := ScrollContainer.new()
	areaHbox.add_child(areaOptionsScroll)
	areaOptionsScroll.set_owner(areaHbox)
	areaOptionsScroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	areaOptionsScroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	areaOptionsScroll.size_flags_horizontal = SIZE_EXPAND_FILL
	areaOptionsScroll.size_flags_vertical = SIZE_SHRINK_CENTER
	areaOptionsScroll.mouse_filter = MOUSE_FILTER_PASS
	
	areaOptionsContainer = HBoxContainer.new()
	areaOptionsScroll.add_child(areaOptionsContainer)
	areaOptionsContainer.set_owner(areaOptionsScroll)
	areaOptionsContainer.size_flags_horizontal = SIZE_EXPAND_FILL
	areaOptionsContainer.size_flags_vertical = SIZE_SHRINK_CENTER + SIZE_EXPAND
	areaOptionsContainer.mouse_filter = MOUSE_FILTER_PASS
	
	if addControlPanelAndContentSeparator:
		var VboxSeparator := Control.new()
		_areaVbox.add_child(VboxSeparator)
		VboxSeparator.set_owner(_areaVbox)
		VboxSeparator.custom_minimum_size = Vector2i(0,controlPanelAndContentSeperatorHeight)
		VboxSeparator.size_flags_horizontal = SIZE_FILL
		VboxSeparator.mouse_filter = MOUSE_FILTER_STOP
	
	if _areaContent != null:
		_areaContent.reparent(_areaVbox)
		_areaContent.set_owner(_areaVbox)
		_areaContent.size_flags_vertical = SIZE_EXPAND_FILL
		_areaContent.mouse_filter = MOUSE_FILTER_PASS

##Reloads WorkspaceArea selector panel to load changes from [WorkspacesAutoloader]
func refreshWorkspaceAreaSelectorPanel()->void:
	workspaceAreaSelectorPanel = Panel.new()
	workspaceAreaSelectorPanel.name = "workspaceSelectorPanel"
	add_child(workspaceAreaSelectorPanel)
	workspaceAreaSelectorPanel.set_owner(self)
	workspaceAreaSelectorPanel.offset_top = 24
	workspaceAreaSelectorPanel.offset_bottom = 0
	workspaceAreaSelectorPanel.position = Vector2i(0,24)
	workspaceAreaSelectorPanel.hide()
	workspaceAreaSelectorPanel.set_anchor_and_offset(SIDE_LEFT,0,0)
	workspaceAreaSelectorPanel.set_anchor_and_offset(SIDE_TOP,0,custom_minimum_size.y)
	workspaceAreaSelectorPanel.set_anchor_and_offset(SIDE_RIGHT,1,0)
	workspaceAreaSelectorPanel.set_anchor_and_offset(SIDE_BOTTOM,0,areaSelectorPanelHeight)
	workspaceAreaSelectorPanel.grow_horizontal = GROW_DIRECTION_BOTH
	workspaceAreaSelectorPanel.grow_vertical = GROW_DIRECTION_BOTH
	workspaceAreaSelectorPanel.mouse_exited.connect(_hideAreaSelectorPanel)
	self.mouse_entered.connect(_hideAreaSelectorPanel)
	
	var selectorMargin := MarginContainer.new()
	workspaceAreaSelectorPanel.add_child(selectorMargin)
	selectorMargin.set_owner(workspaceAreaSelectorPanel)
	selectorMargin.add_theme_constant_override("margin_left",10)
	selectorMargin.add_theme_constant_override("margin_top",5)
	selectorMargin.add_theme_constant_override("margin_right",10)
	selectorMargin.add_theme_constant_override("margin_bottom",5)
	selectorMargin.set_anchor_and_offset(SIDE_LEFT,0,0)
	selectorMargin.set_anchor_and_offset(SIDE_TOP,0,0)
	selectorMargin.set_anchor_and_offset(SIDE_RIGHT,1,0)
	selectorMargin.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	selectorMargin.grow_horizontal = GROW_DIRECTION_BOTH
	selectorMargin.grow_vertical = GROW_DIRECTION_BOTH
	
	var hBox := HBoxContainer.new()
	selectorMargin.add_child(hBox)
	hBox.set_owner(selectorMargin)
	hBox.set_anchor_and_offset(SIDE_LEFT,0,0)
	hBox.set_anchor_and_offset(SIDE_TOP,0,0)
	hBox.set_anchor_and_offset(SIDE_RIGHT,1,0)
	hBox.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	hBox.grow_horizontal = GROW_DIRECTION_BOTH
	hBox.grow_vertical = GROW_DIRECTION_BOTH
	
	var vBox : VBoxContainer
	var columnLabel : Label
	var separator : HSeparator
	var areaSelectButton : Button
	var buttonCall : Callable
	for columnIndex in WorkspacesAutoloader.workspaceCategories.size():
		vBox = VBoxContainer.new()
		vBox.size_flags_horizontal = SIZE_EXPAND_FILL
		vBox.size_flags_vertical = SIZE_FILL
		hBox.add_child(vBox)
		vBox.set_owner(hBox)
		
		columnLabel = Label.new()
		columnLabel.text = WorkspacesAutoloader.workspaceCategories[columnIndex]
		columnLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		columnLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		columnLabel.size_flags_horizontal = SIZE_FILL
		columnLabel.size_flags_vertical = SIZE_SHRINK_CENTER
		columnLabel.mouse_filter = MOUSE_FILTER_PASS
		vBox.add_child(columnLabel)
		columnLabel.set_owner(vBox)
		
		separator = HSeparator.new()
		separator.mouse_filter = MOUSE_FILTER_PASS
		vBox.add_child(separator)
		separator.set_owner(vBox)
		
		for selectorButtonIndex in WorkspacesAutoloader.workspacesNames[columnIndex].size():
			areaSelectButton = Button.new()
			areaSelectButton.text = WorkspacesAutoloader.workspacesNames[columnIndex][selectorButtonIndex]
			areaSelectButton.mouse_filter = MOUSE_FILTER_PASS
			vBox.add_child(areaSelectButton)
			areaSelectButton.set_owner(vBox)
			buttonCall = Callable(self,"switchThisWorkspaceArea")
			buttonCall = buttonCall.bind(columnIndex,selectorButtonIndex)
			areaSelectButton.pressed.connect(buttonCall)

##Switches this [WorkspaceArea] into different from the [param columnIndex] and [param buttonIndex][br]
##[param columnIndex] is the ID starting from 0. Each index represent represent different column or folder
##that was specified in [WorkspacesAutoloader][br]
##[param buttonIndex] is the ID of workspace inside specific column.[br]
##See file loacated here: res://addons/WorkspaceAreas/icons/Documentation/ColumnButtonIndexDoc.png
##And yes I wanted to embed this image into documenation but it's just doesn't work D:[br]
##Column also means the category essentially.. just to clear things up d:
func switchThisWorkspaceArea(columnIndex : int, buttonIndex : int)->void:
	isAboutSwitch.emit()
	
	var selectedWorkspacePath : String = WorkspacesAutoloader.areaFileSystem[columnIndex][buttonIndex]
	var packedWorkspaceArea : PackedScene = load(selectedWorkspacePath)
	
	var createdWorkspace : Control = packedWorkspaceArea.instantiate()
	var thisAreaOrder := get_index()
	get_parent().add_child(createdWorkspace)
	get_parent().move_child(createdWorkspace,thisAreaOrder)
	self.queue_free()

func _mouse_entered()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
