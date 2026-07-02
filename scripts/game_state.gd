extends Node

# ============================================================
#  GAME STATE — estado persistente del juego (autoload)
#  Única fuente de verdad de lo que se guarda. El save es un
#  JSON en user://. La estructura se define ACÁ de entrada
#  (agregar campos a mitad de camino es un dolor de cabeza).
# ============================================================

const SAVE_PATH := "user://savegame.json"
const SAVE_VERSION := 1

# Se emite al desbloquear una habilidad nueva (el player se refresca,
# el HUD muestra el aviso).
signal ability_unlocked(key: String)

# --- Estado persistente ---
var abilities: Dictionary = {}          # { "dash": bool, "double_jump": bool, "wall_jump": bool }
var checkpoint_room: String = ""        # ruta de la sala del último banco
var checkpoint_position: Vector2 = Vector2.ZERO  # posición del banco
var bosses_defeated: Array = []         # ids de jefes vencidos
var secrets_found: Array = []           # ids de secretos encontrados
var max_health: int = 5                 # vida máxima (sube con upgrades)


func _ready() -> void:
	# Por defecto arrancamos una partida nueva en memoria. Cargar un save
	# es decisión del menú (Continuar), no algo automático.
	new_game()


# Resetea el estado a una partida nueva.
func new_game() -> void:
	# Progresión real: las habilidades arrancan bloqueadas y se consiguen
	# jugando (jefes, pickups). Para probar con todo desbloqueado en
	# aislado está test_room (el player ahí ignora el save).
	abilities = {"dash": false, "double_jump": false, "wall_jump": false}
	checkpoint_room = ""
	checkpoint_position = Vector2.ZERO
	bosses_defeated = []
	secrets_found = []
	max_health = 5


# ---- Habilidades -------------------------------------------
func get_ability(key: String) -> bool:
	return abilities.get(key, false)


func unlock_ability(key: String) -> void:
	if get_ability(key):
		return  # ya la tenías; no re-anunciar
	abilities[key] = true
	ability_unlocked.emit(key)


# ---- Checkpoint --------------------------------------------
func set_checkpoint(room: String, position: Vector2) -> void:
	checkpoint_room = room
	checkpoint_position = position


func get_checkpoint() -> Dictionary:
	return {"room": checkpoint_room, "position": checkpoint_position}


# ---- Jefes / secretos --------------------------------------
func is_boss_defeated(id: String) -> bool:
	return id in bosses_defeated


func mark_boss_defeated(id: String) -> void:
	if id not in bosses_defeated:
		bosses_defeated.append(id)


func is_secret_found(id: String) -> bool:
	return id in secrets_found


func mark_secret_found(id: String) -> void:
	if id not in secrets_found:
		secrets_found.append(id)


# ---- Guardado a archivo ------------------------------------
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> void:
	var data := {
		"version": SAVE_VERSION,
		"abilities": abilities,
		"checkpoint_room": checkpoint_room,
		"checkpoint_position": [checkpoint_position.x, checkpoint_position.y],
		"bosses_defeated": bosses_defeated,
		"secrets_found": secrets_found,
		"max_health": max_health,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()


func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false

	abilities = parsed.get("abilities", abilities)
	checkpoint_room = parsed.get("checkpoint_room", "")
	var pos = parsed.get("checkpoint_position", [0, 0])
	checkpoint_position = Vector2(pos[0], pos[1])
	bosses_defeated = parsed.get("bosses_defeated", [])
	secrets_found = parsed.get("secrets_found", [])
	max_health = int(parsed.get("max_health", 5))
	return true
