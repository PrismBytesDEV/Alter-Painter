@tool
class_name SettingsControl extends ScrollContainer

##Universal and modular class for making settings' user interfaces

var _mainVbox : VBoxContainer
@export var categories : Array[settingCategory]

enum settingsArguments {
	##Used by default when no argument is specified
	NONE,
	##Use with property of type [String] so user can use this setting for setting path to something
	ARG_PATH,
	##Use with property of type [Color] so user can only user RGB channels of color
	ARG_RGB,
	##Use with property of type [Color] so user can also manipulate alpha channel of color.
	## By default when user asigns property of type color this argument is used
	ARG_RGBA
}

static var filePathDialog : FileDialog

const _pathLoadIcon : CompressedTexture2D = preload("res://textures/icons/Load.svg")

#path setting from which FileDialog was opened, used to set path to selected file.
static var _currentPathSetting : LineEdit

func _init()->void:
	_mainVbox = VBoxContainer.new()
	add_child(_mainVbox)
	_mainVbox.size_flags_horizontal = SIZE_EXPAND_FILL
	_mainVbox.size_flags_vertical = SIZE_EXPAND_FILL

func _ready()->void:
	if Engine.is_editor_hint():
		return
	
	if filePathDialog == null:
		filePathDialog = FileDialog.new()
		get_tree().root.add_child.call_deferred(filePathDialog)
		filePathDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		filePathDialog.access = FileDialog.ACCESS_FILESYSTEM
		filePathDialog.use_native_dialog = true
		filePathDialog.file_selected.connect(_filePathSelected)
		filePathDialog.hide()
	
	for i in 20:
		addCategory("category " + str(i + 1),false)
		for s in 2:
			categories[i].addSubcategory("subcategory " + str(s + 1),false)
			_addSetting("setting","C:",categories[i].subCategories[s].vbox,emptyCalDebug,settingsArguments.ARG_PATH)

func emptyCalDebug()->void:
	pass

func addCategory(title : String,onTop : bool = true)->void:
	var categoryPanel := settingCategory.new()
	_mainVbox.add_child(categoryPanel)
	if onTop:
		_mainVbox.move_child(categoryPanel,0)
	categoryPanel.size_flags_horizontal = SIZE_EXPAND_FILL
	categoryPanel.custom_minimum_size = Vector2i(0,24)
	
	var categoryLabel := Label.new()
	categoryPanel.add_child(categoryLabel)
	categoryLabel.set_anchor_and_offset(SIDE_LEFT,0,0)
	categoryLabel.set_anchor_and_offset(SIDE_TOP,0,0)
	categoryLabel.set_anchor_and_offset(SIDE_RIGHT,1,0)
	categoryLabel.set_anchor_and_offset(SIDE_BOTTOM,1,0)
	categoryLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	categoryLabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	categoryLabel.text = title
	
	categoryPanel.vbox = VBoxContainer.new()
	_mainVbox.add_child(categoryPanel.vbox)
	if onTop:
		_mainVbox.move_child(categoryPanel.vbox,1)
	categoryPanel.vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	categoryPanel.vbox.custom_minimum_size = Vector2i(0,24)
	
	categories.append(categoryPanel)

func _addSetting(title : String, property : Variant, categoryParent : Control, callable : Callable, argument : settingsArguments = settingsArguments.NONE)->void:
	var propertySplit := HBoxContainer.new()
	categoryParent.add_child(propertySplit)
	propertySplit.size_flags_horizontal = SIZE_EXPAND_FILL
	
	var propertyName := Label.new()
	propertySplit.add_child(propertyName)
	propertyName.size_flags_horizontal = SIZE_FILL
	propertyName.size_flags_vertical = SIZE_EXPAND_FILL
	propertyName.horizontal_alignment = HORIZONTAL_ALIGNMENT_FILL
	propertyName.vertical_alignment = VERTICAL_ALIGNMENT_FILL
	propertyName.text = title
	
	match typeof(property):
		TYPE_BOOL:
			var propertyUI := CheckBox.new()
			propertySplit.add_child(propertyUI)
			propertyUI.size_flags_horizontal = SIZE_EXPAND_FILL
			propertyUI.size_flags_vertical = SIZE_EXPAND_FILL
			propertyUI.button_pressed = property
			propertyUI.toggled.connect(callable)
		TYPE_FLOAT:
			var propertyUI := SpinBox.new()
			propertySplit.add_child(propertyUI)
			propertyUI.custom_arrow_step = 0.1
			propertyUI.step = 0
			propertyUI.rounded = false
			propertyUI.size_flags_horizontal = SIZE_EXPAND_FILL
			propertyUI.size_flags_vertical = SIZE_EXPAND_FILL
			propertyUI.value = property
			propertyUI.value_changed.connect(callable)
		TYPE_INT:
			var propertyUI := SpinBox.new()
			propertySplit.add_child(propertyUI)
			propertyUI.step = 1
			propertyUI.rounded = true
			propertyUI.size_flags_horizontal = SIZE_EXPAND_FILL
			propertyUI.size_flags_vertical = SIZE_EXPAND_FILL
			propertyUI.value = property
			propertyUI.value_changed.connect(callable)
		TYPE_STRING:
			var propertyUI := LineEdit.new()
			propertySplit.add_child(propertyUI)
			propertyUI.size_flags_horizontal = SIZE_EXPAND_FILL
			propertyUI.size_flags_vertical = SIZE_EXPAND_FILL
			propertyUI.text = property
			if argument == settingsArguments.ARG_PATH:
				var pathButton := Button.new()
				propertySplit.add_child(pathButton)
				pathButton.size_flags_vertical = SIZE_EXPAND_FILL
				pathButton.icon = _pathLoadIcon
				pathButton.pressed.connect(_showPathDialog.bind(propertyUI))
		TYPE_COLOR:
			var propertyUI := ColorPickerButton.new()
			propertySplit.add_child(propertyUI)
			propertyUI.size_flags_horizontal = SIZE_EXPAND_FILL
			propertyUI.size_flags_vertical = SIZE_EXPAND_FILL
			propertyUI.color = property
			propertyUI.edit_alpha = argument != settingsArguments.ARG_RGB
			propertyUI.color_changed.connect(callable)

func _showPathDialog(pathLineEdit : LineEdit)->void:
	_currentPathSetting = pathLineEdit
	filePathDialog.show()

func _filePathSelected(path : String)->void:
	_currentPathSetting.text = path

class settingCategory extends Panel:
	var subCategories : Array[settingSubcategory]
	var settings : Array[Control]
	var vbox : VBoxContainer
	
	func addSubcategory(title : String, onTop : bool = true)->void:
		var subCategory := settingSubcategory.new()
		vbox.add_child(subCategory)
		if onTop:
			vbox.move_child(subCategory,0)
		subCategory.size_flags_horizontal = SIZE_EXPAND_FILL
		subCategory.custom_minimum_size = Vector2i(0,24)
		
		subCategory.alignment = HORIZONTAL_ALIGNMENT_LEFT
		subCategory.text = "> " + title
		subCategories.append(subCategory)
		
		subCategory.vbox = VBoxContainer.new()
		vbox.add_child(subCategory.vbox)
		if onTop:
			vbox.move_child(subCategory.vbox,1)
		subCategory.vbox.size_flags_horizontal = SIZE_EXPAND_FILL
		subCategory.vbox.custom_minimum_size = Vector2i(0,24)
		subCategory.vbox.hide()

class settingSubcategory extends Button:
	var vbox : VBoxContainer
	
	func _pressed()->void:
		vbox.visible = !vbox.visible
		if vbox.visible:
			text[0] = 'v'
		else:
			text[0] = '>'
