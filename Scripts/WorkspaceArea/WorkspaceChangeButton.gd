extends Button
class_name WorkspaceChangeButton

var areaSelectorPanel : Panel

func _ready()->void:
	pass

#It is ready, but after areaSelectorPanel is ready to be assigned to variable..
func _READY()->void:
	areaSelectorPanel = %workspaceAreaSelectorPanel
	areaSelectorPanel.hide()
	pressed.connect(_showPanel)
	areaSelectorPanel.mouse_exited.connect(_hidePanel)

func _process(_delta : float)->void:
	pass

func _showPanel()->void:
	areaSelectorPanel.show()

func _hidePanel()->void:
	areaSelectorPanel.hide()
