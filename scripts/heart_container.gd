extends Area2D

# ============================================================
#  HEART CONTAINER — sube la vida máxima en +1 (permanente)
#  Pieza para esconder en los mundos como recompensa de
#  exploración. Cada uno necesita un id ÚNICO para que el save
#  recuerde que ya lo agarraste y no reaparezca.
# ============================================================

## Id único en todo el juego (ej: "p1_heart_1").
@export var container_id: String = ""

var _time: float = 0.0
var _base_y: float = 0.0


func _ready() -> void:
	if container_id != "" and Game.is_secret_found(container_id):
		queue_free()
		return
	_base_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * 2.0) * 5.0


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if container_id != "":
		Game.mark_secret_found(container_id)
	Game.max_health += 1

	# El player toma la vida máxima nueva y queda curado a tope.
	# Sin tipo: max_health/full_heal no están declarados en Node.
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		player.max_health = Game.max_health
		player.full_heal()

	Audio.play("checkpoint")
	queue_free()
