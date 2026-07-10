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
# Se emite al encontrar un amuleto nuevo (el HUD avisa).
signal charm_collected(id: String)
# Se emite al equipar/desequipar amuletos (el player recalcula stats).
signal charms_changed
# Se emite al cambiar la cantidad de antimateria (el HUD se actualiza).
signal currency_changed(total: int)
# Se emite al conseguir un objeto clave (madera, disipador...).
signal key_item_collected(id: String)
# Se emite al juntar un fragmento de la nave (el HUD muestra el conteo).
signal ship_fragment_collected(count: int, total: int)

# ---- Objetos que dan habilidades (identidad espacial) -------
# El nombre que se ve al agarrar el pickup de cada habilidad.
const ABILITY_ITEMS := {
	"dash": {"name": "Propulsor de Vacío"},
	"double_jump": {"name": "Botas Antigravedad"},
	"wall_jump": {"name": "Garfio Magnético"},
}

# ---- Objetos clave -------------------------------------------
# Ítems únicos de la aventura, ligados a planetas concretos.
const KEY_ITEMS := {
	"madera": {
		"name": "Madera",
		"desc": "La materia más rara del universo: solo nace en mundos con vida.",
	},
	"disipador_ionico": {
		"name": "Disipador Iónico",
		"desc": "Dispersa las nieblas densas de los mundos gaseosos.",
	},
	"blindaje_estelar": {
		"name": "Blindaje Estelar",
		"desc": "Placas del Velo: la nave puede cruzar el cinturón de asteroides.",
	},
	"nucleo_pulso": {
		"name": "Núcleo de Pulso",
		"desc": "Energía viva de Raíz: alcanza para llegar a un mundo muerto.",
	},
}

# ---- Fragmentos de la nave (progresión del Páramo) -----------
const SHIP_FRAGMENTS_TOTAL := 3

# ---- Registro de amuletos (estilo Hollow Knight) ------------
# Cada amuleto ocupa muescas. Se equipan/desequipan en los bancos.
# Para agregar uno: entrada acá + su efecto en player.apply_charms()
# + un charm_pickup en el mundo con este id.
const CHARMS := {
	"filo_largo": {
		"name": "Filo Largo",
		"desc": "El golpe alcanza bastante más lejos",
		"cost": 1,
	},
	"garra_veloz": {
		"name": "Garra Veloz",
		"desc": "El dash recarga el doble de rápido",
		"cost": 1,
	},
	"corazon_ferreo": {
		"name": "Corazón Férreo",
		"desc": "+2 de vida máxima",
		"cost": 2,
	},
	"iman_estelar": {
		"name": "Imán Estelar",
		"desc": "Atrae las esquirlas de antimateria desde lejos",
		"cost": 1,
	},
	"oido_fino": {
		"name": "Oído Fino",
		"desc": "La niebla se vuelve más tenue a tu alrededor",
		"cost": 1,
	},
	"savia_espesa": {
		"name": "Savia Espesa",
		"desc": "Quedate quieto unos segundos y regenerás vida",
		"cost": 2,
	},
	"doble_impulso": {
		"name": "Doble Impulso",
		"desc": "Un segundo dash en el aire (y no más)",
		"cost": 2,
	},
}

# ---- Catálogo del Chatarrero (tienda) ------------------------
# Compras únicas; lo comprado se marca en secrets_found con su id.
const SHOP_ITEMS := {
	"shop_heart": {
		"name": "Célula de Vida",
		"desc": "+1 de vida máxima, permanente",
		"price": 45,
	},
	"shop_notch": {
		"name": "Muesca de Amuleto",
		"desc": "+1 muesca para equipar amuletos",
		"price": 60,
	},
	"shop_charm_iman": {
		"name": "Amuleto: Imán Estelar",
		"desc": "Atrae la antimateria desde lejos (1 muesca)",
		"price": 35,
	},
	"shop_charm_oido": {
		"name": "Amuleto: Oído Fino",
		"desc": "La niebla se vuelve más tenue (1 muesca)",
		"price": 40,
	},
	"shop_charm_impulso": {
		"name": "Amuleto: Doble Impulso",
		"desc": "Un segundo dash en el aire (2 muescas)",
		"price": 180,
	},
}

# --- Estado persistente ---
var abilities: Dictionary = {}          # { "dash": bool, "double_jump": bool, "wall_jump": bool }
var checkpoint_room: String = ""        # ruta de la sala del último banco
var checkpoint_position: Vector2 = Vector2.ZERO  # posición del banco
var bosses_defeated: Array = []         # ids de jefes vencidos
var secrets_found: Array = []           # ids de secretos encontrados
var max_health: int = 5                 # vida máxima (sube con upgrades)
var charms_owned: Array = []            # ids de amuletos encontrados
var charms_equipped: Array = []         # ids de amuletos equipados
var charm_notches: int = 3              # muescas disponibles para equipar
var rooms_visited: Array = []           # rutas de salas visitadas (mapa)
var currency: int = 0                   # antimateria (moneda del juego)
var key_items: Array = []               # ids de objetos clave obtenidos

# ---- Antimateria perdida al morir (la "sombra") --------------
var lost_currency: int = 0              # cuánto quedó tirado
var lost_room: String = ""              # en qué sala
var lost_position: Vector2 = Vector2.ZERO
var ship_fragments: Array = []          # ids de fragmentos de nave juntados


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
	charms_owned = []
	charms_equipped = []
	charm_notches = 3
	rooms_visited = []
	currency = 0
	key_items = []
	lost_currency = 0
	lost_room = ""
	lost_position = Vector2.ZERO
	ship_fragments = []


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


# ---- Amuletos ------------------------------------------------
func own_charm(id: String) -> void:
	if id in charms_owned:
		return
	charms_owned.append(id)
	charm_collected.emit(id)


func is_charm_owned(id: String) -> bool:
	return id in charms_owned


func is_charm_equipped(id: String) -> bool:
	return id in charms_equipped


# Muescas ocupadas por los amuletos equipados.
func used_notches() -> int:
	var total := 0
	for id in charms_equipped:
		total += int(CHARMS.get(id, {}).get("cost", 1))
	return total


# Intenta equipar. Devuelve false si no hay muescas suficientes.
func equip_charm(id: String) -> bool:
	if not is_charm_owned(id) or is_charm_equipped(id):
		return false
	var cost: int = CHARMS.get(id, {}).get("cost", 1)
	if used_notches() + cost > charm_notches:
		return false
	charms_equipped.append(id)
	charms_changed.emit()
	return true


func unequip_charm(id: String) -> void:
	if is_charm_equipped(id):
		charms_equipped.erase(id)
		charms_changed.emit()


# ---- Antimateria (moneda) ------------------------------------
func add_currency(amount: int) -> void:
	currency += amount
	currency_changed.emit(currency)


# Al morir: tu antimateria queda tirada donde caíste (estilo HK).
# Si morís de nuevo sin recuperarla, la nueva pila reemplaza a la vieja.
func drop_currency_at(room: String, position: Vector2) -> void:
	if currency <= 0:
		return  # sin plata no hay sombra; la anterior (si había) sigue ahí
	lost_currency = currency
	lost_room = room
	lost_position = position
	currency = 0
	currency_changed.emit(currency)
	# Guardar ya: si cerrás el juego tras morir, la pérdida no se deshace.
	save_game()


# Tocaste la sombra: recuperás todo.
func recover_lost_currency() -> void:
	currency += lost_currency
	lost_currency = 0
	lost_room = ""
	currency_changed.emit(currency)


# ---- Fragmentos de la nave ------------------------------------
func collect_ship_fragment(id: String) -> void:
	if id in ship_fragments:
		return
	ship_fragments.append(id)
	ship_fragment_collected.emit(ship_fragments.size(), SHIP_FRAGMENTS_TOTAL)


func ship_complete() -> bool:
	return ship_fragments.size() >= SHIP_FRAGMENTS_TOTAL


# ---- Objetos clave --------------------------------------------
func has_key_item(id: String) -> bool:
	return id in key_items


func give_key_item(id: String) -> void:
	if id in key_items:
		return
	key_items.append(id)
	key_item_collected.emit(id)


# ---- Mapa: salas visitadas -----------------------------------
func mark_room_visited(path: String) -> void:
	if path not in rooms_visited:
		rooms_visited.append(path)


func is_room_visited(path: String) -> bool:
	return path in rooms_visited


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
		"charms_owned": charms_owned,
		"charms_equipped": charms_equipped,
		"charm_notches": charm_notches,
		"rooms_visited": rooms_visited,
		"currency": currency,
		"key_items": key_items,
		"lost_currency": lost_currency,
		"lost_room": lost_room,
		"lost_position": [lost_position.x, lost_position.y],
		"ship_fragments": ship_fragments,
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
	charms_owned = parsed.get("charms_owned", [])
	charms_equipped = parsed.get("charms_equipped", [])
	charm_notches = int(parsed.get("charm_notches", 3))
	rooms_visited = parsed.get("rooms_visited", [])
	currency = int(parsed.get("currency", 0))
	key_items = parsed.get("key_items", [])
	lost_currency = int(parsed.get("lost_currency", 0))
	lost_room = parsed.get("lost_room", "")
	var lost_pos = parsed.get("lost_position", [0, 0])
	lost_position = Vector2(lost_pos[0], lost_pos[1])
	ship_fragments = parsed.get("ship_fragments", [])
	return true
