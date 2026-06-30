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

@onready var room_container: Node2D = $RoomContainer
@onready var player: CharacterBody2D = $Player
@onready var fade_rect: ColorRect = $Fade/ColorRect

# Sin tipo: accedemos a propiedades de room.gd (camera_limit_*) que Node no tiene.
var current_room = null
var is_transitioning: bool = false


func _ready() -> void:
	add_to_group("rooms")
	if start_room != "":
		_load_room(start_room, start_door)


# La llaman las puertas (room_transition.gd) cuando el player las toca.
func go_to_room(path: String, door_name: String) -> void:
	if is_transitioning:
		return
	_transition(path, door_name)


func _transition(path: String, door_name: String) -> void:
	is_transitioning = true
	await _fade_to(1.0)                 # a negro

	if current_room != null:
		current_room.queue_free()
		current_room = null

	_load_room(path, door_name)
	await get_tree().physics_frame      # dejar que la posición se asiente

	await _fade_to(0.0)                 # de vuelta a la imagen
	await get_tree().physics_frame
	is_transitioning = false


func _load_room(path: String, door_name: String) -> void:
	var packed: PackedScene = load(path)
	current_room = packed.instantiate()
	room_container.add_child(current_room)

	# Colocar al player en la puerta destino (o en el spawn por defecto).
	player.global_position = _find_spawn(door_name)
	player.velocity = Vector2.ZERO

	_apply_camera_limits()


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
