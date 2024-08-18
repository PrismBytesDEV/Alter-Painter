class_name Import3DModelWindow extends Window

@onready var _cancelButton : Button = $MarginContainer/VBoxContainer/HBoxContainer/cancelButton
@onready var _importButton : Button = $MarginContainer/VBoxContainer/HBoxContainer/importButton

func _ready()->void:
	hide()
	
	_cancelButton.pressed.connect(_hideWindow)
	close_requested.connect(_hideWindow)
	_importButton.pressed.connect(_import3DModel)
	_importButton.pressed.connect(_hideWindow)

func _hideWindow()->void:
	self.hide()

func _import3DModel()->void:
	Alter3DScene.load3DAsset(Alter3DScene._import3DModelPath)
