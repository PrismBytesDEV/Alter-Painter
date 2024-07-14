class_name DebugWorkspaceArea extends WorkspaceArea

##This [WorkspaceArea] doesn't serve any purpouse. It was used to test
## and debug [WorkspaceArea]'s code

func _init()->void:
	name = "DebugWorkspaceArea"
	mouse_entered.connect(_mouse_entered_debug_area)
	mouse_exited.connect(_mouse_exited_debug_area)

func _ready()->void:
	setupWorkspaceArea()
	
	for i in 5:
		var optionButton := Button.new()
		optionButton.text = "optionButton " + str(i) 
		areaOptionsContainer.add_child(optionButton)
		#optionButton.size_flags_horizontal = SIZE_EXPAND_FILL

func _mouse_entered_debug_area()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited_debug_area()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
