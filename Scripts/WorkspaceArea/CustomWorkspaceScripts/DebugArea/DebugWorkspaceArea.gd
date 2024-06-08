extends WorkspaceArea

func _ready()->void:
	debug = true
	setupWorkspaceArea()
	
	for i in 5:
		var optionButton := Button.new()
		optionButton.text = "optionButton " + str(i) 
		areaOptionsContainer.add_child(optionButton)
