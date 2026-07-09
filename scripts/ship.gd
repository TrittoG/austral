extends Area2D

# ============================================================
#  SHIP — tu nave (reconstruida), estacionada en la plataforma
#  de vuelo de cada planeta. Interactuar (↑):
#   - Si todavía faltan fragmentos: te lo dice y no despega.
#   - Si está completa: abre el menú de destinos (travel_menu).
#  El gating de destinos vive en el menú (blindaje, núcleo...).
# ============================================================

var player_in_range: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		_board()


func _board() -> void:
	if not Game.ship_complete():
		var dialogue = get_tree().get_first_node_in_group("dialogue")
		if dialogue != null:
			dialogue.show_dialogue("", [
				"A la nave le faltan piezas: %d / %d fragmentos." % [
					Game.ship_fragments.size(), Game.SHIP_FRAGMENTS_TOTAL],
				"Tienen que estar repartidos por el Páramo...",
			])
		return
	var menu = get_tree().get_first_node_in_group("travel_menu")
	if menu != null:
		menu.open()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
