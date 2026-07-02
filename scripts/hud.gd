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


func _ready() -> void:
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


func _on_health_changed(current: int, maximum: int) -> void:
	label.text = "HP  %d / %d" % [current, maximum]


func _on_ability_unlocked(key: String) -> void:
	_show_notice("¡Habilidad desbloqueada: %s!" % key.to_upper().replace("_", " "))


func _on_charm_collected(id: String) -> void:
	var charm_name: String = Game.CHARMS.get(id, {}).get("name", id)
	_show_notice("Amuleto encontrado: %s — equipalo en un banco" % charm_name)


func _show_notice(message: String) -> void:
	notice.text = message
	notice.visible = true
	await get_tree().create_timer(3.0).timeout
	notice.visible = false
