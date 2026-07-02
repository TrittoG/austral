extends StaticBody2D

# ============================================================
#  CURRENCY ROCK — roca de antimateria (rompible)
#  Depósito de moneda estilo Hollow Knight: le pegás unas veces
#  y suelta esquirlas. También podés hacerle pogo. No vuelve a
#  aparecer si la rompiste (id único opcional en el save).
# ============================================================

const COIN_SCENE := preload("res://scenes/props/antimatter.tscn")

## Golpes que aguanta.
@export var health: int = 3
## Esquirlas que suelta al romperse.
@export var currency_drop: int = 6
## Id único para que no reaparezca ("" = reaparece siempre).
@export var rock_id: String = ""

var flash_timer: float = 0.0
var base_color: Color

@onready var body: Polygon2D = $Body


func _ready() -> void:
	if rock_id != "" and Game.is_secret_found(rock_id):
		queue_free()
		return
	base_color = body.color


func _process(delta: float) -> void:
	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0:
			body.color = base_color


# La llama el ataque del player (mismo contrato que los enemigos).
func take_damage(amount: int, _from_position: Vector2) -> void:
	health -= amount
	body.color = Color(1, 1, 1)
	flash_timer = 0.08
	if health <= 0:
		_break()


func _break() -> void:
	if rock_id != "":
		Game.mark_secret_found(rock_id)
	for i in currency_drop:
		var coin := COIN_SCENE.instantiate()
		get_parent().add_child(coin)
		coin.global_position = global_position
	Audio.play("enemy_death", 0.2)
	queue_free()
