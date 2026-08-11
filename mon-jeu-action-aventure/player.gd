extends CharacterBody3D
const SPEED = 7.0
const JUMP_VELOCITY = 4.5

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get input from keyboard AND from the virtual joystick.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var joysticks = get_tree().get_nodes_in_group("joystick")
	if joysticks.size() > 0:
		var joystick_output = joysticks[0].output
		if joystick_output.length() > 0.1:
			input_dir = joystick_output

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
