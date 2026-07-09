extends Area2D

# ============================================================
#  SHIP FRAGMENT — fragmento de tu nave estrellada
#  Hay 3 repartidos por el Páramo. Con los 3, la plataforma de
#  vuelo puede reconstruir la nave y despegar. Persisten en el
#  save (no reaparecen).
# ============================================================

## Id único del fragmento (ej: "fragmento_cabina").
@export var fragment_id: String = ""

var _time: float = 0.0
var _base_y: float = 0.0


func _ready() -> void:
	if fragment_id != "" and fragment_id in Game.ship_fragments:
		queue_free()
		return
	_base_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * 2.0) * 6.0


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	Game.collect_ship_fragment(fragment_id)
	Audio.play("checkpoint")
	queue_free()
