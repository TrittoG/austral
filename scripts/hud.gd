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


func _on_health_changed(current: int, maximum: int) -> void:
	label.text = "HP  %d / %d" % [current, maximum]


func _on_ability_unlocked(key: String) -> void:
	notice.text = "¡Habilidad desbloqueada: %s!" % key.to_upper().replace("_", " ")
	notice.visible = true
	await get_tree().create_timer(3.0).timeout
	notice.visible = false
