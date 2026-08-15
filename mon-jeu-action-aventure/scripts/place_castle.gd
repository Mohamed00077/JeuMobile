@tool
extends EditorScript

const CASTLE_PATH := "res://assets/medieval_village/gltf/buildings/blue/building_castle_blue.gltf"
const CENTER_HEX_COORD := Vector2(20, 20)  # ajuste selon le vrai centre de ta zone


func _run() -> void:
	var root: Node = EditorInterface.get_edited_scene_root()
	if root == null:
		push_error("Aucune scène ouverte dans l'éditeur.")
		return

	var grid: Node = root.get_node_or_null("VillageGridMap")
	if grid == null:
		push_error("VillageGridMap introuvable.")
		return
	if not grid.has_method("map_to_world_HEX"):
		push_error("HexMap n'est pas attaché au GridMap.")
		return

	var castle_scene: PackedScene = load(CASTLE_PATH)
	if castle_scene == null:
		push_error("Impossible de charger : %s — vérifie le chemin exact." % CASTLE_PATH)
		return

	# Conteneur pour organiser les bâtiments séparément des tuiles
	var village_container: Node = root.get_node_or_null("Village")
	if village_container == null:
		village_container = Node3D.new()
		village_container.name = "Village"
		root.add_child(village_container)
		village_container.owner = root

	var castle: Node3D = castle_scene.instantiate()
	castle.name = "Building_Castle"
	village_container.add_child(castle)
	castle.owner = root

	castle.position = grid.map_to_world_HEX(CENTER_HEX_COORD)

	print("Château placé à la coordonnée hex ", CENTER_HEX_COORD, " -> position monde : ", castle.position)
