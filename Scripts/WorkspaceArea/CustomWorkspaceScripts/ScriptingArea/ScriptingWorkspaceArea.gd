class_name ScriptingWorkspaceArea extends WorkspaceArea

##This [WorkspaceArea] is used to quickly write and run some GDScript expresions
## to debug the app at runtime. In future it is planned that this could run entire GDScripts
## and not just single expresions.

@onready var _runCodeIcon : Texture2D = preload("res://textures/icons/Play.svg")
##This button is used to run the written expresion.
var runCodeButton : TextureButton
##This node is used to write expresions and any code.
@onready var codeEditor : CodeEdit = %CodeEdit
##This node can output additional information about the result
@onready var labelOutput : Label = %Label_output_log

func _ready()->void:
	setupWorkspaceArea()
	
	runCodeButton = TextureButton.new()
	runCodeButton.tooltip_text = "Run code"
	runCodeButton.pressed.connect(_runCode)
	runCodeButton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	runCodeButton.texture_normal = _runCodeIcon
	runCodeButton.texture_hover = _runCodeIcon
	runCodeButton.texture_focused = _runCodeIcon
	runCodeButton.texture_pressed = _runCodeIcon
	areaOptionsContainer.add_child(runCodeButton)

func _mouse_entered_LayersArea()->void:
	CurrentMouseHoverArea = self
	if debugCurrentHoverArea:
		modulate = Color.MAGENTA

func _mouse_exited_LayersArea()->void:
	CurrentMouseHoverArea = null
	if debugCurrentHoverArea:
		modulate = Color.WHITE

func _runCode()->void:
	var expression := Expression.new()
	var error := expression.parse(codeEditor.text,["Control","ServerLayersStack"])
	
	if error != OK:
		return expression.get_error_text()
	
	var result : Variant = expression.execute([Control,ServerLayersStack],self,false)
	
	if not expression.has_execute_failed():
		labelOutput.text = str(result)
	else:
		labelOutput.text = ""
	
	var GDCode := GDScript.new()
	GDCode.source_code = codeEditor.text
