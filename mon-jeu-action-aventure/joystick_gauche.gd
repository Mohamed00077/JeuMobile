extends Control

@onready var bouton: ColorRect = $Bouton
@onready var fond: ColorRect = $Fond

var center: Vector2
var radius: float = 80.0
var dragging := false
var output := Vector2.ZERO

func _ready():
	center = fond.position + fond.size / 2.0
	add_to_group("joystick")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			_update(event.position)
		else:
			_reset()
	elif event is InputEventScreenDrag:
		if dragging:
			_update(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
		if event.pressed:
			_update(event.position)
		else:
			_reset()
	elif event is InputEventMouseMotion:
		if dragging:
			_update(event.position)

func _update(pos: Vector2) -> void:
	var delta = pos - center
	if delta.length() > radius:
		delta = delta.normalized() * radius
	bouton.position = center + delta - bouton.size / 2.0
	output = delta / radius

func _reset() -> void:
	dragging = false
	output = Vector2.ZERO
	bouton.position = center - bouton.size / 2.0
