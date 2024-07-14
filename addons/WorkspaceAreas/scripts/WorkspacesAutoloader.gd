class_name WorkspacesAutoloader extends Node

##This class is in autoload and allow to load all categories and workspaces
##So workspaces can further use [method WorkspaceArea.refreshWorkspaceAreaSelectorPanel]
##to reload the selector of available [WorkspaceArea]s

##This path should navigate to the folder
##That have inside it all the other folder that will behave like columns
##Inside that folders there should be .tscn files which area WorkspaceAreas
##That will be loaded from project when switching from area A to area B for example.
##Name for each WorkspaceArea in the picker will be generated automatically
const workspacesPath : String = "res://Scenes/WorkspaceAreas/"
##Optionally if your folder structure is organized in different way from
##what I described in [member WorkspacesAutoloader.workspacesPath][br]
##You can use this to specify path to .json file that should containt first name for columns
##and in each column corresponding paths to .tscn files that are WorkspaceAreas.
##Name for each WorkspaceArea in the picker will be generated automatically
var configFilePath : String

##Stores all the names of loaded categories / columns
static var workspaceCategories : PackedStringArray
##Stores all the names of loaded workspaces
static var workspacesNames : Array[Array]
##Stores all the filePaths to the [member WorkspacesAutoloader.workspacesNames]
static var areaFileSystem : Array[Array]

func _init()->void:
	loadAreasData()

##Call this function staticly [code]WorkspacesAutoloader.loadAreasData()[/code]
##To reload list of all available workspaces inside runtime application
func loadAreasData()->void:
	workspaceCategories.clear()
	workspacesNames.clear()
	areaFileSystem.clear()
	
	if !configFilePath.is_empty():
		var fileContent := FileAccess.open(configFilePath,FileAccess.READ)
		var configDict : Dictionary = JSON.parse_string(fileContent.get_as_text())
		workspaceCategories = configDict.keys()
		
		areaFileSystem.resize(workspaceCategories.size())
		workspacesNames.resize(workspaceCategories.size())
		
		for categoryIndex : int in configDict.keys().size():
			var category : String = configDict.keys()[categoryIndex]
			for workspaceName : String in configDict[category].keys():
				workspacesNames[categoryIndex].append(workspaceName)
				areaFileSystem[categoryIndex].append(configDict[category][workspaceName])
		return
	
	var workspacesDirectiory : DirAccess = DirAccess.open(workspacesPath)
	if workspacesDirectiory == null:
		printerr("Invalid path set in [workspacesPath] can't load WorkspaceAreas!")
		return
	
	workspaceCategories = workspacesDirectiory.get_directories()
	
	areaFileSystem.resize(workspaceCategories.size())
	workspacesNames.resize(workspaceCategories.size())
	
	for i in workspaceCategories.size():
		var category : DirAccess = DirAccess.open(workspacesPath + workspaceCategories[i])
		for workspace in category.get_files():
			var w := workspace.rstrip(".remap")
			w = w.rstrip(".tscn")
			w = w.to_snake_case()
			w = w.capitalize()
			w = w.replace("2d","2D")
			w = w.replace("3d","3D")
			workspacesNames[i].append(w)
			
			var workspaceFilePath := workspacesPath + workspaceCategories[i] + "/" + workspace.get_basename() + "." + workspace.get_extension()
			workspaceFilePath = workspaceFilePath.rstrip(".remap")
			areaFileSystem[i].append(workspaceFilePath)
			#print(areaFileSystem[i])
	
	for categoryID : int in workspaceCategories.size():
		workspaceCategories[categoryID] = workspaceCategories[categoryID].replace("_"," ")
