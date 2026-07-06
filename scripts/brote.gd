extends Node2D

# ============================================================
#  EL BROTE — mascota temporal de Raíz
#  No pelea, no habla: te sigue dando saltitos y hace ruiditos.
#  Colocá una instancia por sala donde deba "seguirte" (cada
#  sala tiene el suyo: la ilusión de que viene con vos).
# ============================================================

## Distancia a la que se queda contento sin acercarse más.
@export var follow_distance: float = 60.0
@export var speed: float = 160.0

var _time: float = 0.0
var _chirp_cooldown: float = 2.0


func _process(delta: float) -> void:
	_time += delta
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var target: Vector2 = player.global_position + Vector2(-follow_distance, -10)
	var dist := global_position.distance_to(target)
	if dist > 12.0:
		global_position = global_position.move_toward(target, speed * delta)

	# Saltito constante (es un brote feliz).
	$Body.position.y = -absf(sin(_time * 6.0)) * 8.0

	# Ruiditos de vez en cuando, solo si está cerca tuyo.
	_chirp_cooldown -= delta
	if _chirp_cooldown <= 0.0 and dist < 140.0:
		_chirp_cooldown = randf_range(3.0, 6.0)
		Audio.play("coin", 0.3, -14.0)
