extends CharacterBody3D
const SPEED = 5.0
const JUMP_VELOCITY = 7.0
const ROTATION_SPEED = 10.0

@onready var anim_player: AnimationPlayer = $Barbarian/AnimationPlayer
@onready var barbarian: Node3D = $Barbarian

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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
		
		var target_angle = atan2(direction.x, direction.z)
		barbarian.rotation.y = lerp_angle(barbarian.rotation.y, target_angle, delta * ROTATION_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if not is_on_floor():
		anim_player.play("Jump_Idle")
	elif direction.length() > 0.1:
		anim_player.play("Running_B")
	else:
		anim_player.play("Idle")
