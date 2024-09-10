class_name AlterProjectSettings extends Resource

##This resource stores all the informations that is related to the project.

##Global texture resolution for all textures that Alter Painter works on
##in current project.
static var textureResolution : Vector2i = Vector2i(512,512):
	set(value):
		mixer.updateResolutionFormat(value)
		textureResolution = value
		painter.resolution = value
		painter.updateResolutionFormat(value)
