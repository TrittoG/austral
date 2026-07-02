extends Area2D

# ============================================================
#  PORTAL — fin de la demo (por ahora)
#  Al tocarlo corta a la pantalla de cierre. Cuando existan más
#  planetas, acá va el viaje interplanetario.
# ============================================================


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
