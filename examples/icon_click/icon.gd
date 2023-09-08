class_name Icon
extends Node3D

@export var flashing: bool = false
@export var max_scale: float = 2.0
@export var min_scale: float = 0.5
@export var swing_offset: float = randf() * 100

@onready var marker: Node3D = %Marker as Node3D
@onready var marker_1: Marker3D = %Marker1 as Marker3D
@onready var marker_2: Marker3D = %Marker2 as Marker3D 
@onready var sprite: Sprite3D = %Sprite as Sprite3D

func _process(delta: float) -> void:
	## 计算缩放比
	var camera: Camera3D = get_viewport().get_camera_3d()
	if not marker.position.is_equal_approx(camera.global_position):
		marker.look_at(camera.global_position)
	
	var point_1: Vector2 = camera.unproject_position(marker_1.global_position)
	var point_2: Vector2 = camera.unproject_position(marker_2.global_position)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var custom_viewport_size: float = viewport_size.y * 0.1
	
	scale *= Vector3.ONE * (custom_viewport_size / point_1.distance_to(point_2))
	## 如果希望一直保持大小的话就注释掉下面的代码
	scale = scale.clamp(Vector3.ONE * min_scale, Vector3.ONE * max_scale)
	
	## 旋转
	sprite.look_at(camera.global_position)
	
	if flashing:
		sprite.modulate = Color(randf(), randf(), randf())
		flashing = false
	else:
		sprite.modulate = Color.WHITE
	
	sprite.position.y = 0.1 * sin(Time.get_ticks_msec() * delta * 0.1 + swing_offset) + 1.0
	
