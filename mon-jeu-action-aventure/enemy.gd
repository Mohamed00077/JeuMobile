extends CharacterBody3D

@export var max_health: int = 30
var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(amount: int) -> void:
	current_health -= amount
	print("Ennemi touché ! PV restants : ", current_health)
	if current_health <= 0:
		die()

func die() -> void:
	print("Ennemi vaincu !")
	queue_free()
