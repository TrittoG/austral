extends Area2D

# ============================================================
#  ABILITY PICKUP — orbe que desbloquea una habilidad
#  Al tocarlo: Game.unlock_ability(ability_key) → el player se
#  refresca solo y el HUD muestra el aviso. Si la habilidad ya
#  está desbloqueada (save), el orbe no aparece.
#
#  ability_key: "dash" | "double_jump" | "wall_jump"
# ============================================================

@export var ability_key: String = "dash"
## Amplitud del flotado (px).
@export var bob_amplitude: float = 6.0
## Velocidad del flotado.
@export var bob_speed: float = 2.5

var _time: float = 0.0
var _base_y: float = 0.0

@onready var label: Label = $Label


func _ready() -> void:
	# Ya la tenés: este orbe no existe más.
	if Game.get_ability(ability_key):
		queue_free()
		return
	_base_y = position.y
	label.text = ability_key.to_upper().replace("_", " ")
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * bob_speed) * bob_amplitude


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	Game.unlock_ability(ability_key)
	Audio.play("checkpoint")
	queue_free()
