@tool
extends EditorScript

const CASTLE_PATH := "res://assets/medieval_village/gltf/buildings/blue/building_castle_blue.gltf"
const CENTER_HEX_COORD := Vector2(20, 20)


func _run() -> void:
	var root: Node = EditorInterface.get_edited_scene_root()
	if root == null:
		push_error("Aucune scène ouverte dans l'éditeur.")
		return

	var grid: Node = root.get_node_or_null("VillageGridMap")
	if grid == null:
		push_error("VillageGridMap introuvable.")
		return

	var village_container: Node = root.get_node_or_null("Village")
	if village_container == null:
		village_container = Node3D.new()
		village_container.name = "Village"
		root.add_child(village_container)
		village_container.owner = root

	var old_castle: Node = village_container.get_node_or_null("Building_Castle")
	if old_castle != null:
		village_container.remove_child(old_castle)
		old_castle.queue_free()

	var building: Node3D = _place_building(CASTLE_PATH, "Building_Castle", grid.map_to_world_HEX(CENTER_HEX_COORD), village_container, root)
	if building:
		print("Château replacé avec collision à : ", building.position)


func _place_building(scene_path: String, node_name: String, world_pos: Vector3, container: Node, owner_root: Node) -> Node3D:
	var packed: PackedScene = load(scene_path)
	if packed == null:
		push_error("Impossible de charger : %s" % scene_path)
		return null

	var instance: Node3D = packed.instantiate()
	instance.name = node_name
	container.add_child(instance)
	instance.owner = owner_root
	instance.position = world_pos

	var mesh_instances: Array[MeshInstance3D] = []
	_collect_mesh_instances(instance, mesh_instances)

	if mesh_instances.is_empty():
		push_warning("Aucun MeshInstance3D trouvé pour %s — pas de collision ajoutée." % node_name)
		return instance

	var world_aabb: AABB = mesh_instances[0].global_transform * mesh_instances[0].get_aabb()
	for i in range(1, mesh_instances.size()):
		var mi: MeshInstance3D = mesh_instances[i]
		world_aabb = world_aabb.merge(mi.global_transform * mi.get_aabb())

	var local_aabb: AABB = instance.global_transform.affine_inverse() * world_aabb

	var body := StaticBody3D.new()
	body.name = "Collision"
	instance.add_child(body)
	body.owner = owner_root

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = local_aabb.size
	shape.shape = box
	body.add_child(shape)
	shape.owner = owner_root
	shape.position = local_aabb.get_center()

	return instance


func _collect_mesh_instances(node: Node, result: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		_collect_mesh_instances(child, result)
