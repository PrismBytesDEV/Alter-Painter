extends Control
class_name WorkspaceArea

#Contains the workspace that mouse is currently hovering over
static var CurrentMouseHoverArea : WorkspaceArea

#Made for debug purposes to show active workspaces tha mouse is hovering over
static var debugCurrentHoverArea : bool = false

var areaVbox : VBoxContainer
var areaOptionsContainer : HBoxContainer
var areaSwitchButton : Button

func _ready()-> void:
	#debugCurrentHoverArea = true
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)
	loadAreas()

func setupWorkspaceArea()->void:
	var areaContent : Control
	if get_child_count() > 0:
		areaContent = get_child(0)
	
	areaVbox = VBoxContainer.new()
	add_child(areaVbox)
	move_child(areaVbox,0)
	areaVbox.anchors_preset = Control.PRESET_FULL_RECT
	
	refreshWorkspaceAreaSelectorPanel()
	
	var areaControlPanel := Panel.new()
	areaVbox.add_child(areaControlPanel)
	areaControlPanel.custom_minimum_size = Vector2i(27,24)
	areaControlPanel.size_flags_horizontal = Control.SIZE_FILL
	areaControlPanel.size_flags_vertical = Control.SIZE_FILL
	
	var areaPanelMargin := MarginContainer.new()
	areaControlPanel.add_child(areaPanelMargin)
	areaControlPanel.anchors_preset = Control.PRESET_FULL_RECT
	areaPanelMargin.add_theme_constant_override("margin_left",16)
	areaPanelMargin.add_theme_constant_override("margin_right",10)
	
	var Hbox := HBoxContainer.new()
	areaPanelMargin.add_child(Hbox)
	Hbox.size_flags_horizontal = Control.SIZE_FILL
	Hbox.size_flags_vertical = Control.SIZE_FILL
	
	areaSwitchButton = Button.new()
	Hbox.add_child(areaSwitchButton)
	areaSwitchButton.set_script("res://Scripts/WorkspaceArea/WorkspaceChangeButton.gd")
	
	var scrollHorizontalContainer := ScrollContainer.new()
	Hbox.add_child(scrollHorizontalContainer)
	scrollHorizontalContainer.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scrollHorizontalContainer.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scrollHorizontalContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scrollHorizontalContainer.size_flags_vertical = Control.SIZE_FILL
	
	areaOptionsContainer = HBoxContainer.new()
	scrollHorizontalContainer.add_child(areaOptionsContainer)
	areaOptionsContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	areaOptionsContainer.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	
	var VboxSeparator := Control.new()
	areaVbox.add_child(VboxSeparator)
	VboxSeparator.custom_minimum_size = Vector2i(0,4)
	VboxSeparator.size_flags_horizontal = Control.SIZE_FILL

func refreshWorkspaceAreaSelectorPanel()->void:
	var workspaceSelectorPanel := Panel.new()
	add_child(workspaceSelectorPanel)
	workspaceSelectorPanel.offset_top = 24
	workspaceSelectorPanel.offset_bottom = 0
	workspaceSelectorPanel.position = Vector2i(0,24)
	
	loadAreas()

func loadAreas()->void:
	var workspacesDirectiory : DirAccess = DirAccess.open("res://Scenes/WorkspaceAreas/")
	var workspaceCategories : PackedStringArray = workspacesDirectiory.get_directories()
	var workspacesNames : Array[String]
	for cat in workspaceCategories:
		var category : DirAccess = DirAccess.open("res://Scenes/WorkspaceAreas/" + cat)
		var workspaces : PackedStringArray = category.get_files()
		for workspace in workspaces:
			var w = workspace.rstrip(".tscn")
			w = w.to_snake_case()
			w = w.capitalize()
			w = w.replace("2d","2D")
			w = w.replace("3d","3D")
			workspacesNames.append(w)
		print(workspacesNames)

func _mouse_entered()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
