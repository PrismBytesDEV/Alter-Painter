class_name ExportTexturesWindow extends Window

@onready var _cancelButton : Button = $MarginContainer/VBoxContainer/HBoxContainer/cancelButton
@onready var _exportButton : Button = $MarginContainer/VBoxContainer/HBoxContainer/exportButton

func _ready()->void:
	self.hide()
	
	_cancelButton.pressed.connect(_hideWindow)
	close_requested.connect(_hideWindow)
	_exportButton.pressed.connect(textureExporter.exportTextures)
	_exportButton.pressed.connect(_hideWindow)

func _hideWindow()->void:
	self.hide()
