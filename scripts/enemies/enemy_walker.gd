extends "res://scripts/enemies/enemy_base.gd"

# ============================================================
#  WALKER — patrullero de piso (cuerpo a cuerpo / contacto)
#  Camina de un lado a otro, se da vuelta al chocar una pared
#  o al llegar al borde de una plataforma. Daña por contacto.
#  Poné move_speed = 0 para un bicho quieto que solo lastima.
# ============================================================

@export var move_speed: float = 60.0
## Distancia hacia adelante donde chequea si sigue habiendo piso.
@export var edge_check_ahead: float = 22.0

var dir: int = 1

@onready var edge_check: RayCast2D = $EdgeCheck


func _on_enemy_ready() -> void:
	_update_edge_check()


func _enemy_physics(_delta: float) -> void:
	velocity.x = dir * move_speed

	# Darse vuelta al chocar una pared.
	if is_on_wall():
		dir *= -1
		_update_edge_check()
	# Darse vuelta al llegar a un borde (no hay piso adelante).
	elif is_on_floor() and not edge_check.is_colliding():
		dir *= -1
		_update_edge_check()


# Reposiciona el raycast de borde adelante, en la dirección de avance.
func _update_edge_check() -> void:
	edge_check.position.x = dir * edge_check_ahead
