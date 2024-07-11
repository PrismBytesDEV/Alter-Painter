class_name Mixer extends RefCounted

static func mixInputs(matID : int)->void:
	var outputAlbedoColor := Color.WHITE
	var layersStack := ServerLayersStack.materialsLayers[matID].layers
	for layer in layersStack:
		outputAlbedoColor *= layer.colors[0]
	
	var material := Alter3DScene.assetMaterials[matID]
	material.albedo_color = outputAlbedoColor
	
	Alter3DScene.assetMaterials[matID] = material
