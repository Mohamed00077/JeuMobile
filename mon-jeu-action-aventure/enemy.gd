extends CharacterBody3D

@export var max_health: int = 30
@export var speed: float = 2.5
@export var detection_range: float = 8.0

var current_health: int
var player: Node3D = null

func _ready() -> void:
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player:
		var distance = global_position.distance_to(player.global_position)
		if distance < detection_range and distance > 1.5:
			var direction = (player.global_position - global_position)
			direction.y = 0
			direction = direction.normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0
			velocity.z = 0

	move_and_slide()

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Ennemi touché ! PV restants : ", current_health)
	if current_health <= 0:
		die()

func die() -> void:
	print("Ennemi vaincu !")
	queue_free()
