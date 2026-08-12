extends CharacterBody3D

@export var max_health: int = 30
@export var speed: float = 2.5
@export var detection_range: float = 8.0
@export var attack_damage: int = 5
@export var attack_cooldown: float = 1.5

var current_health: int
var player: Node3D = null
var attack_timer: float = 0.0

func _ready() -> void:
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	attack_timer -= delta

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
			# Si assez proche et que le cooldown est écoulé, attaque
			if distance <= 1.5 and attack_timer <= 0.0:
				attack()
				attack_timer = attack_cooldown

	move_and_slide()

func attack() -> void:
	print("L'ennemi attaque !")
	var zone_attaque = $ZoneAttaqueEnnemi
	for body in zone_attaque.get_overlapping_bodies():
		if body == self:
			continue
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Ennemi touché ! PV restants : ", current_health)
	if current_health <= 0:
		die()

func die() -> void:
	print("Ennemi vaincu !")
	queue_free()
