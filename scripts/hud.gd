extends CanvasLayer

# ============================================================
#  HUD — display mínimo de vida
#  Se engancha al player por grupo y escucha health_changed.
#  Placeholder de texto; los corazones lindos van en la Fase 10.
# ============================================================

@onready var label: Label = $Label


func _ready() -> void:
	# Esperar un frame asegura que el player ya hizo su _ready
	# (y se agregó al grupo "player").
	await get_tree().process_frame
	# Sin tipo explícito: health_changed no está declarado en Node.
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		_on_health_changed(player.health, player.max_health)


func _on_health_changed(current: int, maximum: int) -> void:
	label.text = "HP  %d / %d" % [current, maximum]
