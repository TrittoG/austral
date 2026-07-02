extends Area2D

# ============================================================
#  KEY ITEM PICKUP — objeto clave tirado en el mundo
#  Ítems únicos de la aventura (madera, disipador iónico...).
#  Al tocarlo queda en el save; el HUD avisa. Si ya lo tenés,
#  no aparece. item_id: una clave de Game.KEY_ITEMS.
# ============================================================

@export var item_id: String = "madera"

var _time: float = 0.0
var _base_y: float = 0.0

@onready var label: Label = $Label


func _ready() -> void:
	if Game.has_key_item(item_id):
		queue_free()
		return
	_base_y = position.y
	label.text = Game.KEY_ITEMS.get(item_id, {}).get("name", item_id)
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * 1.8) * 5.0


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	Game.give_key_item(item_id)
	Audio.play("checkpoint")
	queue_free()
