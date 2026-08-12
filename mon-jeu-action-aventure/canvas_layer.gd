extends CanvasLayer

@onready var barre_de_vie: ColorRect = $BarreDeVie
var player: Node3D = null
var barre_largeur_max: float = 200.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if player:
		var ratio = float(player.current_health) / float(player.max_health)
		ratio = clamp(ratio, 0.0, 1.0)
		barre_de_vie.size.x = barre_largeur_max * ratio
