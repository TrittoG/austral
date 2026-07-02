extends Node

# ============================================================
#  ATLAS (autoload) — datos de mapa del juego
#  Registro central de planetas y salas para los dos mapas:
#  el de la galaxia (qué mundos existen) y el del planeta
#  actual (salas descubiertas + tu ubicación).
#
#  Cuando armes un planeta nuevo: agregá sus salas acá con la
#  posición que ocupan en el "plano" del planeta (offset x/y +
#  tamaño de la sala). El mapa se dibuja solo a partir de esto.
# ============================================================

# pos: posición normalizada (0..1) en la pantalla de la galaxia.
const PLANETS := {
	"planet1": {
		"name": "Páramo del Impacto",
		"color": Color(0.75, 0.55, 0.35),
		"pos": Vector2(0.22, 0.6),
	},
	"planet2": {
		"name": "???",
		"color": Color(0.4, 0.6, 0.8),
		"pos": Vector2(0.52, 0.3),
	},
	"planet3": {
		"name": "???",
		"color": Color(0.6, 0.4, 0.7),
		"pos": Vector2(0.8, 0.62),
	},
}

# rect: dónde queda cada sala en el plano del planeta (coordenadas de
# mundo: offset de la sala + su tamaño). El eje y crece hacia abajo.
const ROOMS := {
	"res://scenes/rooms/planet1/p1_crash.tscn":
		{"planet": "planet1", "rect": Rect2(0, 0, 1600, 640)},
	"res://scenes/rooms/planet1/p1_ravine.tscn":
		{"planet": "planet1", "rect": Rect2(1600, 0, 1100, 640)},
	"res://scenes/rooms/planet1/p1_refuge.tscn":
		{"planet": "planet1", "rect": Rect2(2700, 0, 800, 640)},
	"res://scenes/rooms/planet1/p1_rift.tscn":
		{"planet": "planet1", "rect": Rect2(3500, 0, 2200, 640)},
	"res://scenes/rooms/planet1/p1_boss.tscn":
		{"planet": "planet1", "rect": Rect2(5700, 0, 1100, 640)},
	"res://scenes/rooms/planet1/p1_exit.tscn":
		{"planet": "planet1", "rect": Rect2(5700, -660, 800, 640)},
}


# Planeta al que pertenece una sala ("" si no está mapeada).
func planet_of_room(path: String) -> String:
	return ROOMS.get(path, {}).get("planet", "")


# Salas de un planeta: { path: datos }.
func rooms_for_planet(planet: String) -> Dictionary:
	var result := {}
	for path in ROOMS:
		if ROOMS[path]["planet"] == planet:
			result[path] = ROOMS[path]
	return result


# Un planeta se "conoce" cuando visitaste al menos una de sus salas.
func is_planet_visited(planet: String) -> bool:
	for path in Game.rooms_visited:
		if planet_of_room(path) == planet:
			return true
	return false
