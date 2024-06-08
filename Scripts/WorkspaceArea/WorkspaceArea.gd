extends Control
class_name WorkspaceArea

#Contains the workspace that mouse is currently hovering over
static var CurrentMouseHoverArea : WorkspaceArea

#Made for debug purposes to show active workspaces tha mouse is hovering over
static var debugCurrentHoverArea : bool = false

var areaHbox : HBoxContainer
var areaVbox : VBoxContainer
var areaOptionsContainer : HBoxContainer

var areaSwitchButton : Button

const workspacesPath : String = "res://Scenes/WorkspaceAreas/"

static var workspaceCategories : PackedStringArray
static var workspacesNames : PackedStringArray
static var areaFileSystem : Array[Array]

@export var workspaceAreaIcon : CompressedTexture2D
@export var areaOptionsPanelColor := Color("272727")
@export var addControlPanelAndContentSeparator : bool = true
var controlPanelAndContentSeperatorHeight : int = 4

var debug : bool = false

func _ready()-> void:
	#debugCurrentHoverArea = true
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func setupWorkspaceArea()->void:
	custom_minimum_size = Vector2i(27,24)
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
	areaVbox.mouse_filter = Control.MOUSE_FILTER_PASS
	areaVbox.add_theme_constant_override("separation",0)
	
	refreshWorkspaceAreaSelectorPanel()
	
	var areaControlPanel := Panel.new()
	areaControlPanel.name = "areaControlPanel"
	areaVbox.add_child(areaControlPanel)
	areaControlPanel.custom_minimum_size = self.custom_minimum_size
	areaControlPanel.size_flags_horizontal = SIZE_FILL
	areaControlPanel.size_flags_vertical = SIZE_FILL
	
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
	
	areaHbox = HBoxContainer.new()
	areaHbox.name = "Hbox"
	areaPanelMargin.add_child(areaHbox)
	areaHbox.size_flags_horizontal = SIZE_EXPAND_FILL
	areaHbox.size_flags_vertical = SIZE_FILL
	
	areaSwitchButton = Button.new()
	areaHbox.add_child(areaSwitchButton)
	areaSwitchButton.set_script("res://Scripts/WorkspaceArea/WorkspaceChangeButton.gd")
	areaSwitchButton.icon = workspaceAreaIcon
	areaSwitchButton.size_flags_horizontal = SIZE_FILL + SIZE_SHRINK_BEGIN
	areaSwitchButton.size_flags_vertical = SIZE_FILL
	
	var areaOptionsScroll := ScrollContainer.new()
	areaHbox.add_child(areaOptionsScroll)
	areaOptionsScroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	areaOptionsScroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	areaOptionsScroll.size_flags_horizontal = SIZE_EXPAND_FILL
	areaOptionsScroll.size_flags_vertical = SIZE_SHRINK_CENTER
	
	areaOptionsContainer = HBoxContainer.new()
	areaOptionsScroll.add_child(areaOptionsContainer)
	areaOptionsContainer.size_flags_horizontal = SIZE_EXPAND_FILL
	areaOptionsContainer.size_flags_vertical = SIZE_SHRINK_CENTER + SIZE_EXPAND
	
	if addControlPanelAndContentSeparator:
		var VboxSeparator := Control.new()
		areaVbox.add_child(VboxSeparator)
		VboxSeparator.custom_minimum_size = Vector2i(0,controlPanelAndContentSeperatorHeight)
		VboxSeparator.size_flags_horizontal = SIZE_FILL
	
	if areaContent != null:
		areaContent.reparent(areaVbox)
		areaContent.size_flags_vertical = SIZE_EXPAND_FILL

func refreshWorkspaceAreaSelectorPanel()->void:
	var workspaceSelectorPanel := Panel.new()
	workspaceSelectorPanel.name = "workspaceSelectorPanel"
	add_child(workspaceSelectorPanel)
	workspaceSelectorPanel.offset_top = 24
	workspaceSelectorPanel.offset_bottom = 0
	workspaceSelectorPanel.position = Vector2i(0,24)
	workspaceSelectorPanel.hide()
	
	var selectorMargin := MarginContainer.new()
	workspaceSelectorPanel.add_child(selectorMargin)
	selectorMargin.add_theme_constant_override("margin_left",10)
	selectorMargin.add_theme_constant_override("margin_top",5)
	selectorMargin.add_theme_constant_override("margin_right",10)
	selectorMargin.add_theme_constant_override("margin_bottom",5)
	selectorMargin.anchors_preset = PRESET_FULL_RECT
	
	var hBox := HBoxContainer.new()
	selectorMargin.add_child(hBox)
	hBox.anchors_preset = PRESET_FULL_RECT
	
	for columnIndex in workspaceCategories.size():
		var Vbox := VBoxContainer.new()
		Vbox.size_flags_horizontal = SIZE_EXPAND_FILL
		Vbox.size_flags_vertical = SIZE_FILL
		hBox.add_child(Vbox)
		
		var columnLabel := Label.new()
		columnLabel.text = workspaceCategories[columnIndex]
		columnLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		columnLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		columnLabel.size_flags_horizontal = SIZE_FILL
		columnLabel.size_flags_vertical = SIZE_SHRINK_CENTER
		hBox.add_child(columnLabel)
		
		var separator := HSeparator.new()
		hBox.add_child(separator)

static func loadAreasData()->void:
	var workspacesDirectiory : DirAccess = DirAccess.open(workspacesPath)
	workspaceCategories = workspacesDirectiory.get_directories()
	
	for i in workspaceCategories.size():
		areaFileSystem.append([])
		var category : DirAccess = DirAccess.open(workspacesPath + workspaceCategories[i])
		for workspace in category.get_files():
			var w = workspace.rstrip(".tscn")
			w = w.to_snake_case()
			w = w.capitalize()
			w = w.replace("2d","2D")
			w = w.replace("3d","3D")
			workspacesNames.append(w)
			areaFileSystem[i].append(workspacesPath + workspaceCategories[i] + "/" + workspace.get_basename() + "." + workspace.get_extension())

func _mouse_entered()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
