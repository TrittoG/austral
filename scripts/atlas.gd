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
		"name": "El Velo",
		"color": Color(0.4, 0.6, 0.8),
		"pos": Vector2(0.52, 0.3),
	},
	"planet3": {
		"name": "Raíz",
		"color": Color(0.6, 0.4, 0.7),
		"pos": Vector2(0.8, 0.62),
	},
	"garganta": {
		"name": "La Garganta",
		"color": Color(0.35, 0.2, 0.45),
		"pos": Vector2(0.9, 0.18),
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
	"res://scenes/rooms/planet1/p1_caves.tscn":
		{"planet": "planet1", "rect": Rect2(1700, 660, 1400, 640)},
	"res://scenes/rooms/planet1/p1_tunnels.tscn":
		{"planet": "planet1", "rect": Rect2(880, 660, 800, 640)},
	"res://scenes/rooms/planet1/p1_depths.tscn":
		{"planet": "planet1", "rect": Rect2(-40, 660, 900, 640)},
	"res://scenes/rooms/planet1/p1_chasm.tscn":
		{"planet": "planet1", "rect": Rect2(2050, 1320, 1000, 1280)},
	"res://scenes/rooms/planet1/p1_market.tscn":
		{"planet": "planet1", "rect": Rect2(1030, 1960, 1000, 640)},
	"res://scenes/rooms/planet1/p1_boss2.tscn":
		{"planet": "planet1", "rect": Rect2(3070, 1960, 1100, 640)},
	"res://scenes/rooms/planet2/p2_arrival.tscn":
		{"planet": "planet2", "rect": Rect2(0, 0, 800, 640)},
	"res://scenes/rooms/planet2/p2_ring1.tscn":
		{"planet": "planet2", "rect": Rect2(800, 0, 1600, 640)},
	"res://scenes/rooms/planet2/p2_geysers.tscn":
		{"planet": "planet2", "rect": Rect2(2400, -640, 1100, 1280)},
	"res://scenes/rooms/planet2/p2_hermit.tscn":
		{"planet": "planet2", "rect": Rect2(3500, -640, 800, 640)},
	"res://scenes/rooms/planet2/p2_deep.tscn":
		{"planet": "planet2", "rect": Rect2(3500, 0, 1600, 640)},
	"res://scenes/rooms/planet2/p2_boss.tscn":
		{"planet": "planet2", "rect": Rect2(5100, 0, 1100, 640)},
	"res://scenes/rooms/planet2/p2_core.tscn":
		{"planet": "planet2", "rect": Rect2(6200, 0, 800, 640)},
	"res://scenes/rooms/planet3/p3_arrival.tscn":
		{"planet": "planet3", "rect": Rect2(0, 0, 800, 640)},
	"res://scenes/rooms/planet3/p3_jungle.tscn":
		{"planet": "planet3", "rect": Rect2(800, 0, 1600, 640)},
	"res://scenes/rooms/planet3/p3_frontier.tscn":
		{"planet": "planet3", "rect": Rect2(2400, 0, 1100, 640)},
	"res://scenes/rooms/planet3/p3_mute.tscn":
		{"planet": "planet3", "rect": Rect2(3500, 0, 1600, 640)},
	"res://scenes/rooms/planet3/p3_grove.tscn":
		{"planet": "planet3", "rect": Rect2(5100, 0, 1100, 640)},
	"res://scenes/rooms/planet3/p3_boss.tscn":
		{"planet": "planet3", "rect": Rect2(6200, 0, 1100, 640)},
	"res://scenes/rooms/planet3/p3_seed.tscn":
		{"planet": "planet3", "rect": Rect2(7300, 0, 800, 640)},
	"res://scenes/rooms/garganta/g_arrival.tscn":
		{"planet": "garganta", "rect": Rect2(0, 0, 800, 640)},
	"res://scenes/rooms/garganta/g_gauntlet1.tscn":
		{"planet": "garganta", "rect": Rect2(800, 0, 2200, 640)},
	"res://scenes/rooms/garganta/g_gauntlet2.tscn":
		{"planet": "garganta", "rect": Rect2(3000, -640, 1100, 1280)},
	"res://scenes/rooms/garganta/g_rest.tscn":
		{"planet": "garganta", "rect": Rect2(4100, -640, 800, 640)},
	"res://scenes/rooms/garganta/g_boss.tscn":
		{"planet": "garganta", "rect": Rect2(4900, -640, 1400, 640)},
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
