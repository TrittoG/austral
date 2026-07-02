extends Area2D

# ============================================================
#  CHARM PICKUP — amuleto tirado en el mundo
#  Al tocarlo lo obtenés (queda en el save); se equipa después
#  en un banco. Si ya lo tenés, no aparece.
#
#  charm_id: una clave de Game.CHARMS.
# ============================================================

@export var charm_id: String = "filo_largo"

var _time: float = 0.0
var _base_y: float = 0.0

@onready var label: Label = $Label


func _ready() -> void:
	if Game.is_charm_owned(charm_id):
		queue_free()
		return
	_base_y = position.y
	label.text = Game.CHARMS.get(charm_id, {}).get("name", charm_id)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * 2.2) * 5.0


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	Game.own_charm(charm_id)
	Audio.play("checkpoint")
	queue_free()
