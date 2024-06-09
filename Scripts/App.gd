extends Control
class_name AlterPainter

static var appVersion : String

func _ready():
	appVersion = ProjectSettings.get_setting("application/config/version")
	%appVersionLabel.text = appVersion
