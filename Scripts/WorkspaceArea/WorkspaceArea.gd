extends Control
class_name WorkspaceArea

#Contains the workspace that mouse is currently hovering over
static var CurrentMouseHoverArea : WorkspaceArea

#Made for debug purposes to show active workspaces tha mouse is hovering over
static var debugCurrentHoverArea : bool = false

var areaVbox : VBoxContainer
var areaOptionsContainer : HBoxContainer
var workspaceAreaSelectorPanel : Panel


const workspacesPath : String = "res://Scenes/WorkspaceAreas/"

static var workspacesDataLoaded : bool = false
static var workspaceCategories : PackedStringArray
static var workspacesNames : Array[Array]
static var areaFileSystem : Array[Array]
static var areaSelectorPanelHeight : int = 256

@export var workspaceAreaIcon : CompressedTexture2D
@export var areaOptionsPanelColor := Color("272727")
@export var addControlPanelAndContentSeparator : bool = true
var controlPanelAndContentSeperatorHeight : int = 4

var debug : bool = false

func _init()->void:
	if !workspacesDataLoaded:
		WorkspaceArea.loadAreasData()
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func _ready()->void:
	pass
	#debugCurrentHoverArea = true

func _showAreaSelectorPanel()->void:
	workspaceAreaSelectorPanel.show()

func _hideAreaSelectorPanel()->void:
	workspaceAreaSelectorPanel.hide()

func setupWorkspaceArea()->void:
	custom_minimum_size = Vector2i(27,24)
	
	#This check is require for workspaceArea to be duplicated correctly
	if get_child_count() > 1:
		areaVbox = get_child(0)
		areaOptionsContainer = areaVbox.get_child(0).get_child(0).get_child(0).get_child(1).get_child(0)
		workspaceAreaSelectorPanel = get_child(-2)
		get_child(-1).queue_free()
		return
	
	var areaContent : Control
	if get_child_count() > 0:
		areaContent = get_child(0)
	
	areaVbox = VBoxContainer.new()
	areaVbox.name = "areaVbox"
	add_child(areaVbox)
	move_child(areaVbox,0)
	areaVbox.set_anchor_and_offset(SIDE_LEFT,0,0)
	areaVbox.set_anchor_and_offset(SIDE_TOP,0,0)
	areaVbox.set_anchor_and_offset(SIDE_RIGHT,1,0)
	areaVbox.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	areaVbox.mouse_filter = MOUSE_FILTER_PASS
	areaVbox.add_theme_constant_override("separation",0)
	
	refreshWorkspaceAreaSelectorPanel()
	
	var areaControlPanel := Panel.new()
	areaControlPanel.name = "areaControlPanel"
	areaVbox.add_child(areaControlPanel)
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
	areaPanelMargin.size = areaControlPanel.size
	areaPanelMargin.size_flags_horizontal = SIZE_EXPAND_FILL
	areaPanelMargin.size_flags_vertical = SIZE_EXPAND_FILL
	areaPanelMargin.set_anchor_and_offset(SIDE_LEFT,0,0)
	areaPanelMargin.set_anchor_and_offset(SIDE_TOP,0,0)
	areaPanelMargin.set_anchor_and_offset(SIDE_RIGHT,1,0)
	areaPanelMargin.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	areaPanelMargin.add_theme_constant_override("margin_left",16)
	areaPanelMargin.add_theme_constant_override("margin_right",10)
	areaPanelMargin.mouse_filter = MOUSE_FILTER_PASS
	
	var areaHbox := HBoxContainer.new()
	areaHbox.name = "Hbox"
	areaPanelMargin.add_child(areaHbox)
	areaHbox.size_flags_horizontal = SIZE_EXPAND_FILL
	areaHbox.size_flags_vertical = SIZE_FILL
	areaHbox.mouse_filter = MOUSE_FILTER_PASS
	
	var areaSwitchButton := Button.new()
	areaHbox.add_child(areaSwitchButton)
	#areaSwitchButton.set_script("res://Scripts/WorkspaceArea/WorkspaceChangeButton.gd")
	areaSwitchButton.icon = workspaceAreaIcon
	areaSwitchButton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	areaSwitchButton.size_flags_horizontal = SIZE_SHRINK_CENTER
	areaSwitchButton.size_flags_vertical = SIZE_FILL
	areaSwitchButton.mouse_filter = MOUSE_FILTER_STOP
	areaSwitchButton.pressed.connect(_showAreaSelectorPanel)
	
	var areaOptionsScroll := ScrollContainer.new()
	areaHbox.add_child(areaOptionsScroll)
	areaOptionsScroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	areaOptionsScroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	areaOptionsScroll.size_flags_horizontal = SIZE_EXPAND_FILL
	areaOptionsScroll.size_flags_vertical = SIZE_SHRINK_CENTER
	areaOptionsScroll.mouse_filter = MOUSE_FILTER_PASS
	
	areaOptionsContainer = HBoxContainer.new()
	areaOptionsScroll.add_child(areaOptionsContainer)
	areaOptionsContainer.size_flags_horizontal = SIZE_EXPAND_FILL
	areaOptionsContainer.size_flags_vertical = SIZE_SHRINK_CENTER + SIZE_EXPAND
	areaOptionsContainer.mouse_filter = MOUSE_FILTER_PASS
	
	if addControlPanelAndContentSeparator:
		var VboxSeparator := Control.new()
		areaVbox.add_child(VboxSeparator)
		VboxSeparator.custom_minimum_size = Vector2i(0,controlPanelAndContentSeperatorHeight)
		VboxSeparator.size_flags_horizontal = SIZE_FILL
		VboxSeparator.mouse_filter = MOUSE_FILTER_STOP
	
	if areaContent != null:
		areaContent.reparent(areaVbox)
		areaContent.size_flags_vertical = SIZE_EXPAND_FILL
		areaContent.mouse_filter = MOUSE_FILTER_PASS

func refreshWorkspaceAreaSelectorPanel()->void:
	workspaceAreaSelectorPanel = Panel.new()
	workspaceAreaSelectorPanel.name = "workspaceSelectorPanel"
	add_child(workspaceAreaSelectorPanel)
	workspaceAreaSelectorPanel.offset_top = 24
	workspaceAreaSelectorPanel.offset_bottom = 0
	workspaceAreaSelectorPanel.position = Vector2i(0,24)
	workspaceAreaSelectorPanel.hide()
	workspaceAreaSelectorPanel.set_anchor_and_offset(SIDE_LEFT,0,0)
	workspaceAreaSelectorPanel.set_anchor_and_offset(SIDE_TOP,0,custom_minimum_size.y)
	workspaceAreaSelectorPanel.set_anchor_and_offset(SIDE_RIGHT,1,0)
	workspaceAreaSelectorPanel.set_anchor_and_offset(SIDE_BOTTOM,0,areaSelectorPanelHeight)
	workspaceAreaSelectorPanel.mouse_exited.connect(_hideAreaSelectorPanel)
	self.mouse_entered.connect(_hideAreaSelectorPanel)
	
	var selectorMargin := MarginContainer.new()
	workspaceAreaSelectorPanel.add_child(selectorMargin)
	selectorMargin.add_theme_constant_override("margin_left",10)
	selectorMargin.add_theme_constant_override("margin_top",5)
	selectorMargin.add_theme_constant_override("margin_right",10)
	selectorMargin.add_theme_constant_override("margin_bottom",5)
	selectorMargin.set_anchor_and_offset(SIDE_LEFT,0,0)
	selectorMargin.set_anchor_and_offset(SIDE_TOP,0,0)
	selectorMargin.set_anchor_and_offset(SIDE_RIGHT,1,0)
	selectorMargin.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	
	var hBox := HBoxContainer.new()
	selectorMargin.add_child(hBox)
	hBox.set_anchor_and_offset(SIDE_LEFT,0,0)
	hBox.set_anchor_and_offset(SIDE_TOP,0,0)
	hBox.set_anchor_and_offset(SIDE_RIGHT,1,0)
	hBox.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	
	for columnIndex in workspaceCategories.size():
		var vBox := VBoxContainer.new()
		vBox.size_flags_horizontal = SIZE_EXPAND_FILL
		vBox.size_flags_vertical = SIZE_FILL
		hBox.add_child(vBox)
		
		var columnLabel := Label.new()
		columnLabel.text = workspaceCategories[columnIndex]
		columnLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		columnLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		columnLabel.size_flags_horizontal = SIZE_FILL
		columnLabel.size_flags_vertical = SIZE_SHRINK_CENTER
		columnLabel.mouse_filter = MOUSE_FILTER_PASS
		vBox.add_child(columnLabel)
		
		var separator := HSeparator.new()
		separator.mouse_filter = MOUSE_FILTER_PASS
		vBox.add_child(separator)
		for selectorButtonIndex in workspacesNames[columnIndex].size():
			var areaSelectButton := Button.new()
			areaSelectButton.text = workspacesNames[columnIndex][selectorButtonIndex]
			areaSelectButton.mouse_filter = MOUSE_FILTER_PASS
			vBox.add_child(areaSelectButton)

static func loadAreasData()->void:
	var workspacesDirectiory : DirAccess = DirAccess.open(workspacesPath)
	workspaceCategories = workspacesDirectiory.get_directories()
	areaFileSystem.resize(workspaceCategories.size())
	workspacesNames.resize(workspaceCategories.size())
	
	for i in workspaceCategories.size():
		var category : DirAccess = DirAccess.open(workspacesPath + workspaceCategories[i])
		for workspace in category.get_files():
			var w = workspace.rstrip(".tscn")
			w = w.to_snake_case()
			w = w.capitalize()
			w = w.replace("2d","2D")
			w = w.replace("3d","3D")
			workspacesNames[i].append(w)
			areaFileSystem[i].append(workspacesPath + workspaceCategories[i] + "/" + workspace.get_basename() + "." + workspace.get_extension())
	workspacesDataLoaded = true

func _mouse_entered()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
