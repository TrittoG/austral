extends Area2D

# ============================================================
#  PORTAL — viaje interplanetario
#  Con target_room: viaja a esa sala (otro planeta es solo otra
#  carpeta de salas: misma transición, cambia música y mapa).
#  Con target_room vacío: fin de la demo (pantalla de cierre).
# ============================================================

## Sala de destino ("" = pantalla de fin de demo).
@export_file("*.tscn") var target_room: String = ""
## Ancla de llegada en la sala destino (nodo con hijo Entry).
@export var target_door: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if target_room == "":
		get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
		return
	# Sin tipo: go_to_room no está declarado en Node.
	var manager = get_tree().get_first_node_in_group("rooms")
	if manager != null:
		manager.go_to_room(target_room, target_door)