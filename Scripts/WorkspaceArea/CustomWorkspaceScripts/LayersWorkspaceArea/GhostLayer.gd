class_name GhostFillLayer extends Control

##This class is tied to the "Ghost layer" that is visible while user
## is draging any layer.

#Those two awaits makes sure that the ghost layer wont apper for a one frame
	#	in random place
	#It can be a bit distracting
func _ghostWaitShow()->void:
	await get_tree().process_frame
	await get_tree().process_frame
	show()

func _input(event : InputEvent)->void:
	if event is InputEventMouseMotion:
		#Makes ghost layer follow cursor's position
		position = event.position - (size / 2.0) 

func _notification(notification_type : int)->void:
	match notification_type:
		NOTIFICATION_DRAG_END:
			#When dropping is performed
			#	Required here because this logic can be performed
			#	even if layer is outside LayersStackWorkspaceArea 
			LayersWorkspaceArea.draggingAnyLayer = false
			self.hide()
