class_name TextureExporter extends Node

##This node is responsible for exporting all changes into textures and saving
## and saving them into specified location.

var _exportPath : String

func setExportPath(newPath : String)->void:
	_exportPath = newPath

func _ready()->void:
	pass

func exportTextures()->void:
	for mat in Alter3DScene.modelMaterials:
		var currentPath : String = _exportPath + "/" + str(mat.resource_name)
		if DirAccess.make_dir_recursive_absolute(currentPath) == OK:
			print(mat.resource_name)
			if mat.albedo_texture != null:
				if mat.albedo_texture is ImageTexture:
					mat.albedo_texture.get_image().save_png(currentPath + "/albedo.png")
			if mat.roughness_texture != null:
				if mat.roughness_texture is ImageTexture:
					mat.roughness_texture.get_image().save_png(currentPath + "/roughness.png")
			if mat.metallic_texture != null:
				if mat.metallic_texture is ImageTexture:
					mat.metallic_texture.get_image().save_png(currentPath + "/metalness.png")
