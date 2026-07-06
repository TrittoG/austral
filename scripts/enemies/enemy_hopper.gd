extends "res://scripts/enemies/enemy_base.gd"

# ============================================================
#  HOPPER — brote saltarín (Raíz)
#  Salta hacia el player cada tanto; entre saltos queda quieto.
#  Simple y legible: el peligro es el arco del salto.
# ============================================================

## Pausa entre saltos.
@export var hop_interval: float = 1.3
## Impulso vertical del salto.
@export var hop_velocity_y: float = 380.0
## Impulso horizontal (hacia el player).
@export var hop_velocity_x: float = 170.0

var _cooldown: float = 0.6


func _enemy_physics(delta: float) -> void:
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, 800.0 * delta)
		_cooldown -= delta
		if _cooldown <= 0.0:
			_cooldown = hop_interval
			velocity.y = -hop_velocity_y
			velocity.x = dir_to_player() * hop_velocity_x
