extends "res://scripts/enemies/enemy_base.gd"

# ============================================================
#  CHARGER — embestidor de piso
#  Patrulla tranquilo hasta que te detecta cerca y a su mismo
#  nivel; ahí se lanza en embestida hacia vos. Frena al chocar
#  una pared. Daña por contacto.
# ============================================================

enum State { PATROL, CHARGE }

@export var patrol_speed: float = 40.0
@export var charge_speed: float = 240.0
## A qué distancia te detecta para lanzarse.
@export var detect_range: float = 260.0
## Diferencia de altura máxima para considerarte "a su nivel".
@export var level_tolerance: float = 60.0

var state: int = State.PATROL
var dir: int = 1


func _enemy_physics(_delta: float) -> void:
	match state:
		State.PATROL:
			velocity.x = dir * patrol_speed
			if is_on_wall():
				dir *= -1
			# Detección: cerca y a su mismo nivel → embestir.
			if dist_to_player() < detect_range and height_diff_to_player() < level_tolerance:
				dir = dir_to_player()
				state = State.CHARGE
		State.CHARGE:
			velocity.x = dir * charge_speed
			# Frena contra la pared y vuelve a patrullar.
			if is_on_wall():
				state = State.PATROL
