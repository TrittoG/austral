extends "res://scripts/enemies/enemy_base.gd"

# ============================================================
#  SHOOTER — atacante a distancia
#  Se queda quieto (o casi) y cuando te tiene a tiro dispara un
#  proyectil hacia tu lado cada cierto intervalo. Mantené
#  distancia o cubrite; de cerca es vulnerable.
# ============================================================

## Escena del proyectil a disparar.
@export var projectile_scene: PackedScene
## Segundos entre disparos.
@export var shoot_interval: float = 1.6
## Distancia máxima a la que empieza a dispararte.
@export var detect_range: float = 420.0
## Desde dónde sale el proyectil respecto al centro.
@export var muzzle_offset: float = 26.0

var cooldown: float = 0.0


func _enemy_physics(delta: float) -> void:
	# Quieto: frena cualquier inercia (ej. knockback) de a poco.
	velocity.x = move_toward(velocity.x, 0.0, 400.0 * delta)

	cooldown -= delta
	if projectile_scene == null:
		return
	if dist_to_player() < detect_range and cooldown <= 0.0:
		_shoot()
		cooldown = shoot_interval


func _shoot() -> void:
	var dir := dir_to_player()
	var proj := projectile_scene.instantiate()
	# Lo agregamos a la sala (nuestro padre) para que se descargue con ella.
	get_parent().add_child(proj)
	proj.global_position = global_position + Vector2(dir * muzzle_offset, 0.0)
	if proj.has_method("setup"):
		proj.setup(dir)
