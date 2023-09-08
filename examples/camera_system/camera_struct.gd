@tool
class_name CameraStruct
extends Node

## 相机构造体，包含相机位置与盯着的位置
## 如果相机位置与盯着的位置重合，则模式由轨道改为第一人称自由视角

enum Type {
	ORBIT,
	FIRST_PERSON
}

@onready var _camera: Camera3D = $Camera as Camera3D
@onready var _target_point: MeshInstance3D = $TargetPoint as MeshInstance3D

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if _camera.position != _target_point.position:
			_camera.look_at(_target_point.position)

func hide() -> void:
	for child in get_children():
		if child.has_method("hide"):
			child.hide()

func get_camera_position() -> Vector3:
	return _camera.position

func get_target_position() -> Vector3:
	return _target_point.position

func get_type() -> Type:
	return Type.FIRST_PERSON if get_camera_position().is_equal_approx(get_target_position()) else Type.ORBIT

func get_camera_transform() -> Transform3D:
	return _camera.transform

func get_camera_rotation() -> Vector3:
	return _camera.rotation
