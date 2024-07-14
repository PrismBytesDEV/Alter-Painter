class_name ServerPreview3D extends RefCounted

##This class allows to modify properties of all [Preview3DWorkspaceArea]s at once.

static var _cameras : Array[cameraController] 

static func _addCamera(camera : cameraController)->void:
	_cameras.append(camera)

static func _removeCamera(camera : cameraController)->void:
	var index := _cameras.find(camera)
	_cameras.remove_at(index)

##Recenters all the cameras
static func recenterCameras()->void:
	for camera in _cameras:
		camera.recenterCamera()
