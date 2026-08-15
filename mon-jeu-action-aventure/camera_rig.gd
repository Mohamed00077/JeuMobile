extends Node3D

@export var touch_sensitivity: float = 0.005
@export var pitch_min_deg: float = -30.0
@export var pitch_max_deg: float = 35.0
@export var invert_y: bool = false
@export var recenter_speed: float = 8.0
@export var double_tap_max_delay: float = 0.3
@export var continuous_recenter_deg_per_sec: float = 45.0 
@export var initial_pitch_deg: float = -5.0

@onready var spring_arm: SpringArm3D = $CameraArm
@onready var barbarian: Node3D = get_parent().get_node("Barbarian")

var yaw: float = 0.0
var pitch: float = 0.0
var active_touch_index: int = -1

var is_recentering: bool = false
var last_tap_time: float = -1.0


func _ready() -> void:
	pitch = deg_to_rad(initial_pitch_deg)
	rotation.y = yaw
	spring_arm.rotation.x = pitch


func _process(delta: float) -> void:
	if is_recentering:
		var target_yaw: float = barbarian.rotation.y + PI
		yaw = lerp_angle(yaw, target_yaw, delta * recenter_speed)
		rotation.y = yaw
		if abs(angle_difference(yaw, target_yaw)) < 0.01:
			is_recentering = false
	elif not (active_touch_index != -1 or Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		# Recentrage continu doux, uniquement si le joueur ne touche pas la caméra
		var target_yaw: float = barbarian.rotation.y + PI
		var max_step: float = deg_to_rad(continuous_recenter_deg_per_sec) * delta
		var diff: float = angle_difference(yaw, target_yaw)
		yaw += clamp(diff, -max_step, max_step)
		rotation.y = yaw


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x > get_viewport().size.x * 0.5 and active_touch_index == -1:
				active_touch_index = event.index
				is_recentering = false  # une nouvelle prise en main annule le recentrage

				var now: float = Time.get_ticks_msec() / 1000.0
				if now - last_tap_time < double_tap_max_delay:
					is_recentering = true
				last_tap_time = now
		else:
			if event.index == active_touch_index:
				active_touch_index = -1

	elif event is InputEventScreenDrag:
		if event.index == active_touch_index:
			is_recentering = false
			_apply_look(event.relative)

	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		is_recentering = false
		_apply_look(event.relative)

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var now: float = Time.get_ticks_msec() / 1000.0
		if now - last_tap_time < double_tap_max_delay:
			is_recentering = true
		last_tap_time = now


func _apply_look(relative: Vector2) -> void:
	yaw -= relative.x * touch_sensitivity
	var pitch_delta: float = relative.y * touch_sensitivity
	if invert_y:
		pitch_delta = -pitch_delta
	pitch += pitch_delta

	pitch = clamp(pitch, deg_to_rad(pitch_min_deg), deg_to_rad(pitch_max_deg))

	rotation.y = yaw
	spring_arm.rotation.x = pitch
