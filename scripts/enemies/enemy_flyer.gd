extends "res://scripts/enemies/enemy_base.gd"

# ============================================================
#  FLYER — volador (contacto)
#  Flota con un vaivén vertical (seno) alrededor de un punto
#  que va siguiendo lento al player en horizontal. No usa
#  gravedad (poné use_gravity = false en el inspector).
# ============================================================

## Amplitud del vaivén vertical (px).
@export var bob_amplitude: float = 30.0
## Velocidad del vaivén.
@export var bob_speed: float = 3.0
## Qué tan rápido persigue al player en horizontal (0 = se queda fijo).
@export var follow_speed: float = 35.0
## Ganancia del seguimiento al punto objetivo (más alto = más rígido).
@export var steer_gain: float = 6.0

var origin: Vector2
var time: float = 0.0


func _on_enemy_ready() -> void:
	origin = global_position


func _enemy_physics(delta: float) -> void:
	time += delta

	# El "ancla" sigue lento al player en horizontal.
	if player != null and follow_speed > 0.0:
		origin.x = move_toward(origin.x, player.global_position.x, follow_speed * delta)

	# Punto objetivo: ancla + vaivén vertical.
	var target := origin + Vector2(0.0, sin(time * bob_speed) * bob_amplitude)

	# Steering proporcional hacia el objetivo (suave, sin dividir por delta).
	velocity = (target - global_position) * steer_gain
