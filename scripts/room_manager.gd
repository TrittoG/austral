extends Node2D

# ============================================================
#  ROOM MANAGER — la columna vertebral del metroidvania
#  Carga/descarga la sala actual, posiciona al player en la
#  puerta correcta y hace el fundido entre salas.
#
#  Vive en la escena Main, que también tiene al Player (que
#  NO se destruye al cambiar de sala), el HUD y el Fade.
# ============================================================

## Sala con la que arranca el juego.
@export_file("*.tscn") var start_room: String = ""
## Puerta/spawn donde aparece el player al arrancar ("" = DefaultSpawn).
@export var start_door: String = ""
## Duración de cada mitad del fundido (out y in), en segundos.
@export var fade_time: float = 0.25

const SHADE_SCENE := preload("res://scenes/props/shade.tscn")

@onready var room_container: Node2D = $RoomContainer
@onready var player: CharacterBody2D = $Player
@onready var fade_rect: ColorRect = $Fade/ColorRect

# Sin tipo: accedemos a propiedades de room.gd (camera_limit_*) que Node no tiene.
var current_room = null
var current_room_path: String = ""   # ruta de la sala cargada (para el checkpoint)
var is_transitioning: bool = false


func _ready() -> void:
	add_to_group("rooms")
	# Si hay un checkpoint cargado (vinimos de "Continuar"), arrancamos ahí.
	var cp := Game.get_checkpoint()
	if cp["room"] != "":
		_load_room(cp["room"], "", cp["position"])
	elif start_room != "":
		_load_room(start_room, start_door)


# La llaman las puertas (room_transition.gd) cuando el player las toca.
func go_to_room(path: String, door_name: String) -> void:
	if is_transitioning:
		return
	_transition(path, door_name)


# Reaparece en el último banco guardado (la llama el player al morir).
func respawn_at_checkpoint() -> void:
	if is_transitioning:
		return
	var cp := Game.get_checkpoint()
	var room: String = cp["room"]
	var pos: Vector2 = cp["position"]
	if room == "":
		# Sin checkpoint todavía: volvemos al inicio de la sala inicial.
		room = start_room
		pos = Vector2.INF
	await _transition(room, "", pos)
	# Recuperar la vida al reaparecer.
	var p = get_tree().get_first_node_in_group("player")
	if p != null and p.has_method("full_heal"):
		p.full_heal()


# explicit_pos = Vector2.INF significa "usar la puerta/DefaultSpawn".
func _transition(path: String, door_name: String, explicit_pos := Vector2.INF) -> void:
	is_transitioning = true
	await _fade_to(1.0)                 # a negro

	if current_room != null:
		current_room.queue_free()
		current_room = null

	_load_room(path, door_name, explicit_pos)
	await get_tree().physics_frame      # dejar que la posición se asiente

	await _fade_to(0.0)                 # de vuelta a la imagen
	await get_tree().physics_frame
	is_transitioning = false


func _load_room(path: String, door_name: String, explicit_pos := Vector2.INF) -> void:
	var packed: PackedScene = load(path)
	current_room = packed.instantiate()
	current_room_path = path
	room_container.add_child(current_room)

	# Posición: explícita (respawn en checkpoint) o resuelta por puerta/spawn.
	if explicit_pos != Vector2.INF:
		player.global_position = explicit_pos
	else:
		player.global_position = _find_spawn(door_name)
	player.velocity = Vector2.ZERO

	_apply_camera_limits()

	# El mapa se revela por salas visitadas.
	Game.mark_room_visited(path)

	# Si moriste en esta sala con antimateria encima, tu sombra te espera.
	if Game.lost_currency > 0 and Game.lost_room == path:
		var shade := SHADE_SCENE.instantiate()
		current_room.add_child(shade)
		shade.position = Game.lost_position

	# Música de la sala (si comparte pista con la anterior, sigue de largo).
	if "music_track" in current_room:
		Audio.play_music_path(current_room.music_track)

	# Niebla: se activa en salas con fog, salvo que tengas el disipador.
	var fog_overlay = get_node_or_null("FogOverlay")
	if fog_overlay != null:
		var room_has_fog: bool = ("fog" in current_room) and current_room.fog
		fog_overlay.visible = room_has_fog and not Game.has_key_item("disipador_ionico")


# Busca el Marker2D "Entry" dentro de la puerta destino. Si no hay puerta,
# cae al "DefaultSpawn" de la sala. Último recurso: el origen.
func _find_spawn(door_name: String) -> Vector2:
	if door_name != "":
		var door: Node = current_room.find_child(door_name, true, false)
		if door != null and door.has_node("Entry"):
			return (door.get_node("Entry") as Node2D).global_position
	var spawn: Node = current_room.find_child("DefaultSpawn", true, false)
	if spawn != null:
		return (spawn as Node2D).global_position
	return Vector2.ZERO


# Cada sala define sus límites de cámara; se los aplicamos a la cámara del
# player y reseteamos el suavizado para que no "viaje" entre salas.
func _apply_camera_limits() -> void:
	if current_room == null:
		return
	var cam := player.get_node("Camera2D") as Camera2D
	cam.limit_left = current_room.camera_limit_left
	cam.limit_top = current_room.camera_limit_top
	cam.limit_right = current_room.camera_limit_right
	cam.limit_bottom = current_room.camera_limit_bottom
	cam.reset_smoothing()


func _fade_to(target_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", target_alpha, fade_time)
	await tween.finished
