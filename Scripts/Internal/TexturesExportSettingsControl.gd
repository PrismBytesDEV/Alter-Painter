@tool
class_name TextureExportSettingsControl extends SettingsControl

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
	
	_addSetting("path", "",_mainVbox,_setNewExportPath,settingsArguments.ARG_PATH_OPEN_DIR)

func _setNewExportPath(new_path : String)->void:
	textureExporter.setExportPath(new_path)
