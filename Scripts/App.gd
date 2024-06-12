extends Control
class_name AlterPainter

static var appVersion : String

const workspacesPath : String = "res://Scenes/WorkspaceAreas/"
static var workspaceCategories : PackedStringArray
static var workspacesNames : Array[Array]
static var areaFileSystem : Array[Array]

@onready var import3DFileDialog : FileDialog = %Import3DModelWindow
@onready var appEditButtons : HBoxContainer = $VBoxContainer/AppEditPanel/AppEditButtons

func _init():
	AlterPainter.loadAreasData()

func _ready():
	appVersion = ProjectSettings.get_setting("application/config/version")
	%appVersionLabel.text = appVersion
	var projectSettingsButton : MenuButton = appEditButtons.get_child(0)
	projectSettingsButton.get_popup().id_pressed.connect(menuProjectSettingsItemSelected)

static func loadAreasData()->void:
	var workspacesDirectiory : DirAccess = DirAccess.open(workspacesPath)
	workspaceCategories = workspacesDirectiory.get_directories()
	areaFileSystem.resize(workspaceCategories.size())
	workspacesNames.resize(workspaceCategories.size())
	
	for i in workspaceCategories.size():
		var category : DirAccess = DirAccess.open(workspacesPath + workspaceCategories[i])
		for workspace in category.get_files():
			var w = workspace.rstrip(".remap")
			w = w.rstrip(".tscn")
			w = w.to_snake_case()
			w = w.capitalize()
			w = w.replace("2d","2D")
			w = w.replace("3d","3D")
			workspacesNames[i].append(w)
			
			var workspaceFilePath := workspacesPath + workspaceCategories[i] + "/" + workspace.get_basename() + "." + workspace.get_extension()
			workspaceFilePath = workspaceFilePath.rstrip(".remap")
			areaFileSystem[i].append(workspaceFilePath)
			print(areaFileSystem[i])

func menuProjectSettingsItemSelected(index : int)->void:
	match index:
		0:
			import3DFileDialog.show()

func load3DAsset(path : String)->void:
	print(path)
	var gltfDocument := GLTFDocument.new()
	var gltfState := GLTFState.new()
	gltfDocument.append_from_file(path,gltfState)
	
