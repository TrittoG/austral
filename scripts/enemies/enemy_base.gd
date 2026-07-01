extends CharacterBody2D

# ============================================================
#  ENEMY BASE — framework de enemigo común (reutilizable)
#  Maneja lo compartido: vida, recibir golpes (flash + knockback
#  + hitstop), gravedad opcional, muerte, detección del player.
#  La IA concreta (cómo se mueve/ataca cada bicho) va en el
#  script que extiende a este, vía los "virtuales" del final.
#
#  Para que el player le pegue: el enemigo debe tener un Area2D
#  "Hurtbox" en el grupo "enemy_hurtbox".
#  Para que dañe al tocar: un Area2D en el grupo "enemy_hitbox".
# ============================================================

signal died

@export_group("Vida")
@export var max_health: int = 4

@export_group("Daño y físico")
## Daño por contacto (lo aplica el Area2D de contacto; informativo acá).
@export var contact_damage: int = 1
## Si cae por gravedad (apagar para voladores).
@export var use_gravity: bool = true
@export var gravity: float = 980.0

@export_group("Feedback al ser golpeado")
@export var knockback_force: float = 180.0
@export var flash_color: Color = Color(1, 1, 1)
@export var flash_time: float = 0.07
## Congelamiento al impactarlo (0 = sin hitstop, mejor para hordas).
@export var hit_hitstop: float = 0.02

var health: int
var is_dead: bool = false
var flash_timer: float = 0.0
var base_color: Color
var player: Node2D = null

@onready var body: ColorRect = $Body


func _ready() -> void:
	add_to_group("enemy")
	health = max_health
	base_color = body.color
	_acquire_player()
	_on_enemy_ready()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if player == null or not is_instance_valid(player):
		_acquire_player()
	_update_flash(delta)

	if use_gravity and not is_on_floor():
		velocity.y += gravity * delta

	_enemy_physics(delta)
	move_and_slide()


# La llama el ataque del player (hurtbox en grupo "enemy_hurtbox").
func take_damage(amount: int, from_position: Vector2) -> void:
	if is_dead:
		return
	health -= amount
	body.color = flash_color
	flash_timer = flash_time
	if hit_hitstop > 0.0:
		Juice.hitstop(hit_hitstop)

	# Knockback en sentido contrario al atacante.
	var dir := signf(global_position.x - from_position.x)
	if dir == 0.0:
		dir = 1.0
	velocity.x = dir * knockback_force
	if use_gravity:
		velocity.y = -knockback_force * 0.4

	if health <= 0:
		_die()


func _die() -> void:
	is_dead = true
	Audio.play("enemy_death", 0.12)
	died.emit()
	_on_death()
	queue_free()


func _update_flash(delta: float) -> void:
	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0:
			body.color = base_color


func _acquire_player() -> void:
	player = get_tree().get_first_node_in_group("player")


# Dirección al player: -1 izquierda, 1 derecha.
func dir_to_player() -> int:
	if player == null:
		return 1
	return 1 if player.global_position.x > global_position.x else -1


func dist_to_player() -> float:
	if player == null:
		return 999999.0
	return global_position.distance_to(player.global_position)


# Diferencia de altura con el player (para decidir si "te ve" en su nivel).
func height_diff_to_player() -> float:
	if player == null:
		return 999999.0
	return absf(global_position.y - player.global_position.y)


# ---- "Virtuales": cada bicho concreto los sobreescribe ----
func _on_enemy_ready() -> void:
	pass

func _enemy_physics(_delta: float) -> void:
	pass

func _on_death() -> void:
	pass
