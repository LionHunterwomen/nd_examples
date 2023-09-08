class_name CameraGimbal
extends Node3D

## 主相机，有轨道模式与第一人称模式

enum Type {
	NONE,
	ORBIT,
	FIRST_PERSON
}

## 鼠标移动的作用倍率
@export var mouse_sensitivity: float = 0.005
@export var current_type: Type = Type.NONE: set = switch_movement_type

@onready var _inner: Node3D = %Inner as Node3D
@onready var _character_body: CharacterBody3D = %CharacterBody as CharacterBody3D
#@onready var _collision_shape: CollisionShape3D = %CollisionShape as CollisionShape3D
@onready var _camera: Camera3D = %Camera as Camera3D
@onready var _up: RayCast3D = $Inner/CharacterBody/Up as RayCast3D
@onready var _down: RayCast3D = $Inner/CharacterBody/Down as RayCast3D

## 处理的当前移动模式下的输入操作的回调
var _movement_input_behavior: Callable = Callable()
## 处理的当前移动模式下的每帧操作的回调
var _movement_physices_process_behavior: Callable = Callable()


var _is_active: bool = false

## 切换相机的行为模式
func switch_movement_type(new_type: Type) -> void:
	if new_type == current_type:
		return
	
	match current_type:
		Type.NONE:
			_exit_none()
		Type.ORBIT:
			_exit_orbit()
		Type.FIRST_PERSON:
			_exit_first_person()
	
	current_type = new_type
	
	match current_type:
		Type.NONE:
			_enter_none()
		Type.ORBIT:
			_enter_orbit()
		Type.FIRST_PERSON:
			_enter_first_person()

## 让相机看向某个点, 使用世界坐标系
func set_looking_at(pos: Vector3) -> void:
	match current_type:
		Type.ORBIT:
			var temp: Transform3D = _character_body.global_transform
			rotation.y = _character_body.global_rotation.y
			_inner.rotation.x = _character_body.global_rotation.x
			position = pos
			_character_body.global_transform = temp
			_character_body.rotation = Vector3.ZERO
		_:
			pass

## 设置相机的坐标，使用世界坐标系, 不会导致物理碰撞
func custom_set_global_transform(trans: Transform3D) -> void:
	_character_body.global_transform = trans

func _ready() -> void:
	_enter_none()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_is_active = event.is_pressed()
	_movement_input_behavior.call(event)

func _physics_process(delta: float) -> void:
	_movement_physices_process_behavior.call(delta)

func _enter_none() -> void:
	set_process_unhandled_input(false)
	set_physics_process(false)

func _exit_none() -> void:
	set_process_unhandled_input(true)
	set_physics_process(true)

func _enter_orbit() -> void:
	_movement_input_behavior = _orbit_input
	_movement_physices_process_behavior = _orbit_physics_process

func _exit_orbit() -> void:
	_movement_input_behavior = Callable()
	_movement_physices_process_behavior = Callable()

func _enter_first_person() -> void:
	_movement_input_behavior = _first_person_input
	_movement_physices_process_behavior = _first_person_physics_process
	
	position = _character_body.global_position
	_inner.global_rotation.x = _character_body.global_rotation.x
	rotation.y = _character_body.global_rotation.y
	_character_body.position = Vector3.ZERO

func _exit_first_person() -> void:
	_movement_input_behavior = Callable()
	_movement_physices_process_behavior = Callable()

func _orbit_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		_character_body.velocity += _character_body.global_transform.basis.z
	elif event.is_action_pressed("zoom_out"):
		_character_body.velocity += - _character_body.global_transform.basis.z
	
	if not _is_active:
		return
	
	if event is InputEventMouseMotion:
		if event.relative.x != 0.0:
			rotate_object_local(Vector3.UP, - event.relative.x * mouse_sensitivity)
		if event.relative.y != 0.0 and not _down.is_colliding() and not _up.is_colliding():
			var y_rotation: float = clampf(- event.relative.y, -30.0, 30.0)
			_inner.rotate_object_local(Vector3.RIGHT, y_rotation * mouse_sensitivity)

func _orbit_physics_process(_delta: float) -> void:
	_character_body.move_and_slide()
	
	_character_body.velocity = _character_body.velocity.lerp(Vector3.ZERO, 1.0)

func _first_person_input(event: InputEvent) -> void:
	if not _is_active:
		return
	
	if event is InputEventMouseMotion:
		if event.relative.x != 0.0:
			rotate_object_local(transform.basis.y, - event.relative.x * mouse_sensitivity)
		if event.relative.y != 0.0:
			var y_rotation: float = clampf(- event.relative.y, -30.0, 30.0)
			_inner.rotate_object_local(Vector3.RIGHT, y_rotation * mouse_sensitivity)

func _first_person_physics_process(delta: float) -> void:
	var velocity: Vector3 = Vector3.ZERO
	velocity.z = Input.get_axis("move_forward", "move_backward")
	velocity.y = Input.get_axis("move_up", "move_down")
	velocity.x = Input.get_axis("move_left", "move_right")
	_character_body.velocity +=  _character_body.global_transform.basis * velocity
	_character_body.velocity = _character_body.velocity.normalized() * 2000.0 * delta
	_character_body.move_and_slide()
	
	position = _character_body.global_position
	_character_body.position = Vector3.ZERO
	
	_character_body.velocity = _character_body.velocity.lerp(Vector3.ZERO, 1.0)
