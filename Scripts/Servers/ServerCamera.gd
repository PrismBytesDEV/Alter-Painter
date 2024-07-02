extends RefCounted
class_name ServerCamera

static var _cameras : Array[cameraController] 

static func addCamera(camera : cameraController)->void:
	_cameras.append(camera)

static func removeCamera(camera : cameraController)->void:
	var index := _cameras.find(camera)
	_cameras.remove_at(index)

static func recenterCameras()->void:
	for camera in _cameras:
		camera.recenterCamera()
