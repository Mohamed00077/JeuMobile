@tool
extends GridMap
class_name HexMap

## Script porté en GDScript 2.0 (Godot 4) à partir de :
## https://github.com/musniro/Godot_Hex_Gridmap
## Permet de placer des tuiles hexagonales (ex: KayKit) sur un GridMap standard
## en corrigeant automatiquement le décalage en quinconce nécessaire.
##
## IMPORTANT : réglez Cell > Size sur (1, 0.2, 1.732) dans l'inspecteur
## avant d'utiliser ce script (testé pour les hextiles KayKit).
##
## Utilisez set_cell_HEX(x, y, tile_id) pour placer une tuile à une
## coordonnée hexagonale logique (x, y) — PAS de clic manuel dans l'éditeur,
## la grille brute sous-jacente est deux fois plus dense que les tuiles.

signal on_left_click(hexmap, mappos, mouse_pos)
signal on_hover(hexmap, mappos, mouse_pos)

@export var camera_path: NodePath
@export var always_show_coordinates: bool = true

var cam: Node = null


func _ready() -> void:
	if camera_path != NodePath():
		cam = get_node(camera_path)


func get_distance_between(a: Vector2, b: Vector2) -> float:
	var d: Vector2 = b - a
	return max(max(abs(d.x), abs(d.y)), abs(d.x + d.y))


func set_obj_pos_HEX(object: Node3D, obj_mappos: Vector2) -> void:
	object.position = map_to_world_HEX(obj_mappos)


func world_to_map_HEX(pos: Vector3) -> Vector2:
	var mappos: Vector3i = local_to_map(pos)
	return _correct_mappos(Vector2(mappos.x, mappos.z))


func map_to_world_HEX(mappos: Vector2) -> Vector3:
	var uncorrected: Vector2 = _uncorrect_mappos(mappos)
	return map_to_local(Vector3i(int(uncorrected.x), 0, int(uncorrected.y)))


func has_tile_HEX(mappos: Vector2) -> bool:
	return get_cell_HEX(int(mappos.x), int(mappos.y)) > -1


func get_cell_HEX(x: int, y: int) -> int:
	var mappos: Vector2 = _uncorrect_mappos(Vector2(x, y))
	return get_cell_item(Vector3i(int(mappos.x), 0, int(mappos.y)))


func set_cell_HEX(x: int, y: int, tile_id: int) -> void:
	var mappos: Vector2 = _uncorrect_mappos(Vector2(x, y))
	set_cell_item(Vector3i(int(mappos.x), 0, int(mappos.y)), tile_id)


func _correct_mappos(mappos: Vector2) -> Vector2:
	mappos.x /= 2.0
	mappos.x = ceil(mappos.x)
	mappos = Vector2(mappos.x - floor(mappos.y / 2.0), mappos.y)
	return mappos


func _uncorrect_mappos(mappos: Vector2) -> Vector2:
	mappos = Vector2(mappos.x + floor(mappos.y / 2.0), mappos.y)
	mappos.x *= 2.0
	if not _is_odd(mappos.y):
		mappos.x -= 1.0
	return mappos


func _is_odd(x: float) -> bool:
	return int(x) % 2 == 1


var cprevpos: Vector2
var cprevtile: int = -1


func _on_hexmap_left_click(_hexmap, mappos: Vector2, _mouse_pos) -> void:
	if cprevtile != -1:
		set_cell_HEX(int(cprevpos.x), int(cprevpos.y), cprevtile)
	cprevtile = get_cell_HEX(int(mappos.x), int(mappos.y))
	cprevpos = mappos


func _unhandled_input(event: InputEvent) -> void:
	if cam == null:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mappos = _mouse_pos_to_map(event.position)
		if mappos != null:
			emit_signal("on_left_click", self, mappos, event.position)
	if event is InputEventMouseMotion:
		var mappos = _mouse_pos_to_map(event.position)
		if mappos != null:
			emit_signal("on_hover", self, mappos, event.position)


func _mouse_pos_to_map(mouse_pos: Vector2):
	if not cam.has_method("get_mousepos3d"):
		return null
	var world_pos = cam.get_mousepos3d(mouse_pos)
	if world_pos == null:
		return null
	return world_to_map_HEX(world_pos)
