extends Control

# ============================================================
#  MAP VIEW — dibuja los dos mapas (lo controla map_screen)
#  - "planet": las salas VISITADAS del planeta actual, la sala
#    en la que estás resaltada y un punto con tu posición.
#  - "galaxy": los mundos que existen; los no visitados son "???".
#  Todo placeholder con draw_*; el arte va después.
# ============================================================

var mode: String = "planet"

const ROOM_FILL := Color(0.18, 0.2, 0.26, 1)
const ROOM_CURRENT := Color(0.3, 0.38, 0.5, 1)
const ROOM_BORDER := Color(0.55, 0.6, 0.7, 1)
const PLAYER_DOT := Color(0.5, 0.9, 1.0, 1)


func _draw() -> void:
	if mode == "planet":
		_draw_planet()
	else:
		_draw_galaxy()


# ------------------------------------------------------------
#  MAPA DEL PLANETA ACTUAL
# ------------------------------------------------------------
func _draw_planet() -> void:
	var font := ThemeDB.fallback_font
	var manager = get_tree().get_first_node_in_group("rooms")
	var current_path: String = manager.current_room_path if manager != null else ""
	var planet := Atlas.planet_of_room(current_path)

	if planet == "":
		draw_string(font, Vector2(0, size.y * 0.5), "Sin datos de mapa de esta zona",
				HORIZONTAL_ALIGNMENT_CENTER, size.x, 20, Color(0.6, 0.6, 0.6))
		return

	var rooms := Atlas.rooms_for_planet(planet)

	# Encuadre fijo: el marco abarca TODO el planeta (no solo lo visto),
	# así el mapa no "salta" a medida que descubrís salas.
	var bounds: Rect2
	var first := true
	for path in rooms:
		var rect: Rect2 = rooms[path]["rect"]
		bounds = rect if first else bounds.merge(rect)
		first = false

	var margin := 30.0
	var scale_factor: float = minf(
		(size.x - margin * 2.0) / bounds.size.x,
		(size.y - margin * 2.0) / bounds.size.y
	)
	var origin := (size - bounds.size * scale_factor) * 0.5 - bounds.position * scale_factor

	for path in rooms:
		if not Game.is_room_visited(path):
			continue  # lo no visitado no existe en el mapa
		var rect: Rect2 = rooms[path]["rect"]
		var draw_r := Rect2(origin + rect.position * scale_factor, rect.size * scale_factor)
		draw_r = draw_r.grow(-2.0)  # separación entre salas
		var fill := ROOM_CURRENT if path == current_path else ROOM_FILL
		draw_rect(draw_r, fill)
		draw_rect(draw_r, ROOM_BORDER, false, 2.0)

	# Tu ubicación dentro de la sala actual.
	var player = get_tree().get_first_node_in_group("player")
	if player != null and rooms.has(current_path):
		var room_rect: Rect2 = rooms[current_path]["rect"]
		var world_pos: Vector2 = room_rect.position + (player as Node2D).global_position
		draw_circle(origin + world_pos * scale_factor, 5.0, PLAYER_DOT)


# ------------------------------------------------------------
#  MAPA DE LA GALAXIA
# ------------------------------------------------------------
func _draw_galaxy() -> void:
	var font := ThemeDB.fallback_font
	var manager = get_tree().get_first_node_in_group("rooms")
	var current_planet := ""
	if manager != null:
		current_planet = Atlas.planet_of_room(manager.current_room_path)

	for id in Atlas.PLANETS:
		var data: Dictionary = Atlas.PLANETS[id]
		var center: Vector2 = Vector2(data["pos"].x * size.x, data["pos"].y * size.y)
		var visited: bool = Atlas.is_planet_visited(id)

		var color: Color = data["color"] if visited else Color(0.2, 0.2, 0.24)
		draw_circle(center, 30.0, color)

		# Anillo en el planeta donde estás parado.
		if id == current_planet:
			draw_arc(center, 38.0, 0.0, TAU, 48, Color(1, 1, 1, 0.9), 2.5)

		var planet_name: String = data["name"] if visited else "???"
		draw_string(font, center + Vector2(-150, 58), planet_name,
				HORIZONTAL_ALIGNMENT_CENTER, 300, 16,
				Color(0.9, 0.9, 0.85) if visited else Color(0.5, 0.5, 0.5))
