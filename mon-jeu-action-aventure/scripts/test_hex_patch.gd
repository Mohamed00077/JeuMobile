@tool
extends EditorScript

const TILE_NAME := "hex_grass"
const PATCH_SIZE := 5


func _run() -> void:
	var root: Node = EditorInterface.get_edited_scene_root()
	if root == null:
		push_error("Aucune scène ouverte dans l'éditeur.")
		return

	var grid: Node = root.get_node_or_null("VillageGridMap")
	if grid == null:
		push_error("VillageGridMap introuvable comme enfant direct de : %s" % root.name)
		return
	if not grid.has_method("set_cell_HEX"):
		push_error("Le nœud trouvé n'a pas de méthode set_cell_HEX — HexMap est-il attaché ?")
		return

	var lib: MeshLibrary = grid.mesh_library
	if lib == null:
		push_error("Aucune MeshLibrary assignée au GridMap.")
		return

	var tile_id := -1
	for id in lib.get_item_list():
		if lib.get_item_name(id) == TILE_NAME:
			tile_id = id
			break

	if tile_id == -1:
		push_error("Tuile '%s' introuvable. Noms disponibles : %s" % [TILE_NAME, _list_names(lib)])
		return

	print("ID trouvé pour '%s' : %d" % [TILE_NAME, tile_id])

	for x in range(PATCH_SIZE):
		for y in range(PATCH_SIZE):
			grid.set_cell_HEX(x, y, tile_id)

	print("Patch 5x5 d'herbe placé. Vérifiez l'alignement dans la vue 3D.")


func _list_names(lib: MeshLibrary) -> String:
	var names: Array = []
	for id in lib.get_item_list():
		names.append(lib.get_item_name(id))
	return str(names)
