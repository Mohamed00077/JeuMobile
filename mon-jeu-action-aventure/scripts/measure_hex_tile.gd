@tool
extends EditorScript
 
## Exécutez ce script une fois (Fichier > Exécuter ou Ctrl+Shift+X)
## pour connaître les dimensions EXACTES d'une tuile hexagonale.
## Le résultat s'affiche dans la console "Sortie" en bas de l'éditeur.
 
const TILE_PATH := "res://assets/medieval_village/gltf/tiles/base/hex_grass.gltf"
 
 
func _run() -> void:
	var packed: PackedScene = load(TILE_PATH)
	if packed == null:
		push_error("Impossible de charger : %s — vérifiez le chemin exact." % TILE_PATH)
		return
 
	var instance: Node = packed.instantiate()
 
	# On cherche le premier MeshInstance3D dans l'arbre (peu importe la profondeur)
	var mesh_instance: MeshInstance3D = _find_mesh_instance(instance)
	if mesh_instance == null:
		push_error("Aucun MeshInstance3D trouvé dans la scène chargée.")
		instance.free()
		return
 
	var aabb: AABB = mesh_instance.get_aabb()
	print("=== Dimensions de la tuile (AABB local, avant transform) ===")
	print("Taille (size)   : ", aabb.size)
	print("Largeur (X)     : ", aabb.size.x)
	print("Hauteur (Y)     : ", aabb.size.y)
	print("Profondeur (Z)  : ", aabb.size.z)
	print("")
	print("Suggestion Cell Size pour GridMap (X, Y, Z) :")
	print("  X = ", aabb.size.x / 2.0, "  (moitié de la largeur, pour la grille doublée)")
	print("  Y = 0.2  (hauteur arbitraire, peu importante pour des tuiles plates)")
	print("  Z = ", aabb.size.z * 0.75, "  (~75% de la profondeur, chevauchement standard des rangées hexagonales)")
 
	instance.free()
 
 
func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result := _find_mesh_instance(child)
		if result != null:
			return result
	return null
 
