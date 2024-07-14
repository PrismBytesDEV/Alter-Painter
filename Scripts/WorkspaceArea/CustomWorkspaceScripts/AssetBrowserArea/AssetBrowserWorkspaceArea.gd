class_name AssetBrowserWorkspaceArea extends WorkspaceArea

##This is the [WorkspaceArea] that is meant to be used as asset explorer
##of user's content libraries like procedural materials, brushes, textures etc.[br]
##(currently it is in placeholder state, in other words needs functionalities to be implemented)

func _init()->void:
	name = "AssetBrowserWorkspaceArea"
	mouse_entered.connect(_mouse_entered_AssetBrowser)
	mouse_exited.connect(_mouse_exited_AssetBrowser)

func _ready()->void:
	setupWorkspaceArea()

func _mouse_entered_AssetBrowser()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited_AssetBrowser()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE
