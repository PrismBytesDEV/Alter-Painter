#class_name Mixer 
extends RefCounted
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
static func mixInputs(matID : int, recalculateMode : int = -1)->void:
	var outputAlbedoColor := Color.WHITE
	var outputRoughnessValue : float = 0.5
	var outputMetalnessValue : float = 0.5
	var layersStack := ServerLayersStack.materialsLayers[matID].layers
	var material := Alter3DScene.modelMaterials[matID]
	match recalculateMode:
		ServerLayersStack.layerChannels.Albedo:
			for layerID : int in layersStack.size():
				var layer : FillLayerData = layersStack[layerID]
				if !layer.visible:
					continue
				outputAlbedoColor = lerp(outputAlbedoColor,layer.colors[ServerLayersStack.layerChannels.Albedo],layer.opacity)
			
			material.albedo_color = outputAlbedoColor
		ServerLayersStack.layerChannels.Roughness:
			for layerID : int in layersStack.size():
				var layer : FillLayerData = layersStack[layerID]
				if !layer.visible:
					continue
				outputRoughnessValue = lerp(outputRoughnessValue,layer.colors[ServerLayersStack.layerChannels.Roughness],layer.opacity)
			
			material.roughness = outputRoughnessValue
		ServerLayersStack.layerChannels.Metalness:
			for layerID : int in layersStack.size():
				var layer : FillLayerData = layersStack[layerID]
				if !layer.visible:
					continue
				outputMetalnessValue = lerp(outputMetalnessValue,layer.colors[ServerLayersStack.layerChannels.Metalness],layer.opacity)
			
			material.metallic = outputMetalnessValue
		_:
			for layerID : int in layersStack.size():
				var layer : FillLayerData = layersStack[layerID]
				if !layer.visible:
					continue
				outputAlbedoColor = lerp(outputAlbedoColor,layer.colors[ServerLayersStack.layerChannels.Albedo],layer.opacity)
				outputRoughnessValue = lerp(outputRoughnessValue,layer.colors[ServerLayersStack.layerChannels.Roughness],layer.opacity)
				outputMetalnessValue = lerp(outputMetalnessValue,layer.colors[ServerLayersStack.layerChannels.Metalness],layer.opacity)
			
			material.albedo_color = outputAlbedoColor
			material.roughness = outputRoughnessValue
			material.metallic = outputMetalnessValue
	
	Alter3DScene.modelMaterials[matID] = material
