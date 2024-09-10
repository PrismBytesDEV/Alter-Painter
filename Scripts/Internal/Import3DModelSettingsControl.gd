@tool
class_name Import3DModelSettingsControl extends SettingsControl

@onready var _import3DModelWindow : Window = %Import3DModelWindow

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
	_addSetting("Target texture resolution", mixer.textureResolutions,_mainVbox,_setNewTextureRes,settingsArguments.ARG_ENUM)

func _setNew3DModelPath(path : String)->void:
	Alter3DScene._import3DModelPath = path
	_import3DModelWindow._importButton.disabled = false

func _setNewTextureRes(enumKey : int)->void:
	var res : int = str(Mixer.textureResolutions.keys()[enumKey]).trim_prefix("_").to_int()
	var resVec := Vector2i.ONE * res
	print("new texture resolution set ", res, "x",res)
	AlterProjectSettings.textureResolution = resVec
