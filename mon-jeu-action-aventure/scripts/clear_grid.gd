@tool
extends EditorScript


func _run() -> void:
	var root: Node = EditorInterface.get_edited_scene_root()
	if root == null:
		push_error("Aucune scène ouverte dans l'éditeur.")
		return

	var grid: Node = root.get_node_or_null("VillageGridMap")
	if grid == null:
		push_error("VillageGridMap introuvable comme enfant direct de : %s" % root.name)
		return

	grid.clear()
	print("GridMap entièrement vidé.")
