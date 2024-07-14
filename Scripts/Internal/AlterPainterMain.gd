class_name AlterPainter extends Control

##This class is the main part of the application

##Stores text information about currently used version of the software
static var appVersion : String

@onready var _import3DFileDialog : FileDialog = %Import3DModelWindow
##It's a parent of all option buttons that are in the top left corner of the application[br]
##You can use this to add your own buttons for various settings and such.[br]
##You can also acces it by using %AppEditButtons
@onready var appEditButtons : HBoxContainer = %AppEditButtons

func _ready()->void:
	appVersion = ProjectSettings.get_setting("application/config/version")
	%appVersionLabel.text = appVersion
	var projectSettingsButton : MenuButton = appEditButtons.get_child(0)
	projectSettingsButton.get_popup().id_pressed.connect(_menuProjectSettingsItemSelected)

#This is a function that is connected to the popup menu
#of the "File" button in left top corner
func _menuProjectSettingsItemSelected(index : int)->void:
	match index:
		0:
			_import3DFileDialog.show()
