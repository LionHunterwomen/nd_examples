extends Node3D


func _physics_process(delta: float) -> void:
	## 射线检测有没有碰撞
	var camera: Camera3D = get_viewport().get_camera_3d()
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var from: Vector3 = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to: Vector3 = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * camera.far
	var ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	ray.collide_with_areas = true
	var result: Dictionary = space_state.intersect_ray(ray)
	
	if result.is_empty():
		return
	## 如果有的话就根据需求处理逻辑
	if result.collider is IconArea:
		var icon: Icon = result.collider.get_icon()
		icon.flashing = true
		
