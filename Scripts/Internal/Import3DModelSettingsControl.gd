@tool
class_name Import3DModelSettingsControl extends SettingsControl

func _ready()->void:
	if Engine.is_editor_hint():
		return
	
	if filePathDialog == null:
		filePathDialog = FileDialog.new()
		get_tree().root.add_child.call_deferred(filePathDialog)
		filePathDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		filePathDialog.access = FileDialog.ACCESS_FILESYSTEM
		filePathDialog.use_native_dialog = true
		filePathDialog.dir_selected.connect(_pathSelected)
		filePathDialog.file_selected.connect(_pathSelected)
		filePathDialog.hide()
	
	_addSetting("3D model path", "",_mainVbox,_setNew3DModelPath,settingsArguments.ARG_PATH_OPEN_FILE)
	_addSetting("Target texture resolution", mixer.textureResolutions,_mainVbox,_setNew3DModelPath,settingsArguments.ARG_ENUM)

func _setNew3DModelPath(path : String)->void:
	Alter3DScene._import3DModelPath = path
