extends Area2D

# ============================================================
#  ROOM TRANSITION — una puerta entre salas
#  Area2D en el borde de una sala. Cuando el player la toca,
#  le pide al RoomManager que cargue la sala destino y lo
#  coloque en la puerta correspondiente de esa sala.
#
#  Debe tener un hijo Marker2D llamado "Entry": ahí aparece
#  el player cuando ENTRA a esta sala por esta puerta. El
#  Entry va hacia adentro de la sala, lejos del Area2D, para
#  no re-disparar la transición apenas llegás.
# ============================================================

## Escena de la sala a la que lleva esta puerta.
@export_file("*.tscn") var target_room: String = ""
## Nombre de la puerta en la sala destino donde aparece el player.
@export var target_door: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if target_room == "":
		return
	# Sin tipo: go_to_room no está declarado en Node.
	var manager = get_tree().get_first_node_in_group("rooms")
	if manager != null:
		manager.go_to_room(target_room, target_door)
