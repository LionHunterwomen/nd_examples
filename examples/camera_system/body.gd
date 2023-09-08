extends CharacterBody3D

func move(delta: float) -> void:
	if Input.get_mouse_button_mask() & MOUSE_BUTTON_LEFT:
		var mouse_veolcity: Vector2 = Input.get_last_mouse_velocity()
		rotation.x -= mouse_veolcity.y * delta * 0.005
		rotation.y -= mouse_veolcity.x * delta * 0.005
		rotation.x = clampf(rotation.x, -PI/2, PI/2)
	
	velocity += Input.get_axis("move_forward", "move_backward") * transform.basis.z
	velocity += Input.get_axis("move_left", "move_right") * transform.basis.x
	velocity += Input.get_axis("move_up", "move_down") * transform.basis.y
	
	move_and_slide()
	velocity = velocity.lerp(Vector3.ZERO, 0.1)
