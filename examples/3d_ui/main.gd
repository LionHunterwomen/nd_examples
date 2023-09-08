extends Node3D

## 面片的尺寸
var _quad_mesh_size: Vector2
## 鼠标是否在面片内
var _is_mouse_inside: bool = false
## 当前事件是否是鼠标事件
var _is_mouse_held: bool = false
var _last_mouse_pos3D: Vector3 = Vector3.INF
var _last_mouse_pos2D: Vector2 = Vector2.INF

@onready var node_viewport: SubViewport = $SubViewport as SubViewport
@onready var node_quad: MeshInstance3D = $MeshInstance3D as MeshInstance3D
@onready var node_area: Area3D = $MeshInstance3D/Area

func _ready() -> void:
	node_area.mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered() -> void:
	_is_mouse_inside = true

func _unhandled_input(event: InputEvent) -> void:
	var is_mouse_event: bool = false
	if event is InputEventMouse or event is InputEventMouse:
		is_mouse_event = true

	## 如果不是鼠标事件则可以直接传递
	if is_mouse_event and (_is_mouse_inside or _is_mouse_held):
		handle_mouse(event)
	elif not is_mouse_event:
		node_viewport.push_input(event)

func handle_mouse(event) -> void:
	## 需要根据面片的尺寸去算uv
	_quad_mesh_size = node_quad.mesh.size

	if event is InputEventMouseButton or event is InputEventScreenTouch:
		_is_mouse_held = event.pressed
	## 获取鼠标射线跟面片碰撞的位置
	var mouse_pos3D: Vector3 = find_mouse(event.global_position)

	_is_mouse_inside = mouse_pos3D.is_finite()
	if _is_mouse_inside:
		## 如果在面片内，通过面片变换的逆矩阵算出在面片坐标系内的坐标
		mouse_pos3D = node_area.global_transform.affine_inverse() * mouse_pos3D
		_last_mouse_pos3D = mouse_pos3D
	else:
		mouse_pos3D = _last_mouse_pos3D
		if not mouse_pos3D.is_finite():
			mouse_pos3D = Vector3.ZERO
	
	## 下面是用面片尺寸和当前位置算出uv坐标，再根据子视窗的尺寸算出相应位置
	var mouse_pos2D = Vector2(mouse_pos3D.x, -mouse_pos3D.y)

	mouse_pos2D.x += _quad_mesh_size.x / 2
	mouse_pos2D.y += _quad_mesh_size.y / 2
	
	mouse_pos2D.x = mouse_pos2D.x / _quad_mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / _quad_mesh_size.y

	mouse_pos2D.x = mouse_pos2D.x * node_viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * node_viewport.size.y
	
	event.position = mouse_pos2D
	event.global_position = mouse_pos2D
	if event is InputEventMouseMotion:
		if not _last_mouse_pos2D.is_finite():
			event.relative = Vector2(0, 0)
		else:
			event.relative = mouse_pos2D - _last_mouse_pos2D
	_last_mouse_pos2D = mouse_pos2D
	## 算出对应位置后让子视窗接受这个事件
	node_viewport.push_input(event)

func find_mouse(global_position) -> Vector3:
	## 获取鼠标射线跟面片碰撞的位置
	var camera: Camera3D = get_viewport().get_camera_3d()

	var from = camera.project_ray_origin(global_position)
	var dist = find_further_distance_to(camera.transform.origin)
	var to = from + camera.project_ray_normal(global_position) * dist

	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	ray.collide_with_areas = true
	var result: Dictionary = space_state.intersect_ray(ray)
	
	if result.size() > 0:
		return result.position
	else:
		return Vector3.INF

func find_further_distance_to(origin):
	var edges = []
	edges.append(node_area.to_global(Vector3(_quad_mesh_size.x / 2, _quad_mesh_size.y / 2, 0)))
	edges.append(node_area.to_global(Vector3(_quad_mesh_size.x / 2, -_quad_mesh_size.y / 2, 0)))
	edges.append(node_area.to_global(Vector3(-_quad_mesh_size.x / 2, _quad_mesh_size.y / 2, 0)))
	edges.append(node_area.to_global(Vector3(-_quad_mesh_size.x / 2, -_quad_mesh_size.y / 2, 0)))

	var far_dist = 0
	var temp_dist
	for edge in edges:
		temp_dist = origin.distance_to(edge)
		if temp_dist > far_dist:
			far_dist = temp_dist

	return far_dist
