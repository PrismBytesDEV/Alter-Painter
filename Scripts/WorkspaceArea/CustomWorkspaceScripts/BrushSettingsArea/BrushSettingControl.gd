@tool
class_name BrushSettingControl extends SettingsControl

##This class is responsible for displaying and managing UI for brush's settings

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
	
	addCategory("Universal brush settings")
	_addSetting("brush color",Color.BLACK,categories[0].vbox,brushColorChanged,settingsArguments.ARG_RGB)
	_addSetting("brush roughness",0.5,categories[0].vbox,brushRoughnessChanged,settingsArguments.ARG_PICKER)
	_addSetting("brush metalness",0.0,categories[0].vbox,brushMetalnessChanged,settingsArguments.ARG_PICKER)
	_addSetting("brush size",10.0,categories[0].vbox,brushSizeChanged)
	_addSetting("brush opacity",1.0,categories[0].vbox,brushOpacityChanged)
	_addSetting("brush strength",1.0,categories[0].vbox,brushStrengthChanged)
	addCategory("Brush specific settings",false)
	categories[1].addSubcategory("sub setting")
	_addSetting("setting","not implemented yet!",categories[1].subCategories[0].vbox,placeholder)

func brushColorChanged(newColor : Color)->void:
	ServerBrushSettings.currentBrushProfile.brushColor = newColor

func brushRoughnessChanged(newValue : float)->void:
	ServerBrushSettings.currentBrushProfile.brushRougness = newValue

func brushMetalnessChanged(newValue : float)->void:
	ServerBrushSettings.currentBrushProfile.brushMetalness = newValue

func brushSizeChanged(newValue : float)->void:
	ServerBrushSettings.currentBrushProfile.brushSize = newValue

func brushOpacityChanged(newValue : float)->void:
	ServerBrushSettings.currentBrushProfile.brushOpacity = newValue

func brushStrengthChanged(newValue : float)->void:
	ServerBrushSettings.currentBrushProfile.brushStrength = newValue

func placeholder()->void:
	pass
