class_name Mixer extends RefCounted

##[Mixer] does the heavy lifting with combinig layers from the stack
##into result textures that are further applied into materials

##List of all available mix operations
##that mixer can perform on texture with a layer
enum mixTypes
{
	Add,
	Subtract,
	Multiply
}

##Running this method starts processing all the layers of the materiarial of [param matID]
## this id must be contained in boundries of [member Alter3DScene.modelMaterials].[br]
##And at the end it applies the changes into the material specified by the id
##This function is called every time when layer is added, removed or modified
static func mixInputs(matID : int)->void:
	var outputAlbedoColor := Color.WHITE
	var layersStack := ServerLayersStack.materialsLayers[matID].layers
	for layerID : int in layersStack.size():
		var layer : FillLayerData = layersStack[layerID]
		if !layer.visible:
			continue
		outputAlbedoColor = lerp(outputAlbedoColor,layer.colors[0],layer.opacity) 
	
	var material := Alter3DScene.modelMaterials[matID]
	material.albedo_color = outputAlbedoColor
	
	Alter3DScene.modelMaterials[matID] = material
