extends CanvasLayer

# ============================================================
#  HUD — display mínimo de vida + avisos
#  Se engancha al player por grupo y escucha health_changed.
#  Si existe un Label "Notice", muestra el aviso de habilidad
#  desbloqueada unos segundos. Placeholder; el HUD lindo va
#  en la Fase 10.
# ============================================================

@onready var label: Label = $Label
@onready var notice: Label = get_node_or_null("Notice")
@onready var currency_label: Label = get_node_or_null("Currency")


func _ready() -> void:
	add_to_group("hud")
	# Esperar un frame asegura que el player ya hizo su _ready
	# (y se agregó al grupo "player").
	await get_tree().process_frame
	# Sin tipo explícito: health_changed no está declarado en Node.
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.health, player.max_health)
	if notice != null:
		notice.visible = false
		Game.ability_unlocked.connect(_on_ability_unlocked)
		Game.charm_collected.connect(_on_charm_collected)
		Game.key_item_collected.connect(_on_key_item_collected)
		Game.ship_fragment_collected.connect(_on_ship_fragment)
	if currency_label != null:
		Game.currency_changed.connect(_on_currency_changed)
		_on_currency_changed(Game.currency)


func _on_health_changed(current: int, maximum: int) -> void:
	label.text = "HP  %d / %d" % [current, maximum]


func _on_ability_unlocked(key: String) -> void:
	# El objeto espacial que otorga la habilidad (Propulsor de Vacío, etc.).
	var item_name: String = Game.ABILITY_ITEMS.get(key, {}).get("name", "")
	var ability := key.to_upper().replace("_", " ")
	if item_name != "":
		_show_notice("¡%s! Nueva habilidad: %s" % [item_name, ability])
	else:
		_show_notice("¡Habilidad desbloqueada: %s!" % ability)


func _on_charm_collected(id: String) -> void:
	var charm_name: String = Game.CHARMS.get(id, {}).get("name", id)
	_show_notice("Amuleto encontrado: %s — equipalo en un banco" % charm_name)


func _on_key_item_collected(id: String) -> void:
	var item_name: String = Game.KEY_ITEMS.get(id, {}).get("name", id)
	_show_notice("Objeto clave: %s" % item_name)


func _on_ship_fragment(count: int, total: int) -> void:
	if count >= total:
		_show_notice("¡Fragmento de nave (%d/%d)! La nave está COMPLETA" % [count, total])
	else:
		_show_notice("Fragmento de nave (%d/%d)" % [count, total])


func _on_currency_changed(total: int) -> void:
	currency_label.text = "◆ %d" % total


# Aviso genérico desde afuera (ej: el modo dios del player).
func notify(message: String) -> void:
	if notice != null:
		_show_notice(message)


func _show_notice(message: String) -> void:
	notice.text = message
	notice.visible = true
	await get_tree().create_timer(3.0).timeout
	notice.visible = false
