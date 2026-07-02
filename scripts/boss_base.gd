extends CharacterBody2D

# ============================================================
#  BOSS BASE — framework reutilizable de jefe
#  Maneja lo común: vida, recibir golpes, fases por umbral de
#  vida, gravedad, muerte (marca el jefe como vencido y premia
#  una habilidad). La máquina de estados concreta (los ataques)
#  va en el script que extiende a este (ej: boss_01.gd) vía los
#  métodos "virtuales" de abajo.
# ============================================================

signal health_changed(current: int, maximum: int)
signal defeated

const COIN_SCENE := preload("res://scenes/props/antimatter.tscn")

@export_group("Vida")
@export var max_health: int = 30
## Esquirlas de antimateria que suelta al caer.
@export var currency_drop: int = 30
## Id único para el save (qué jefes ya venciste).
@export var boss_id: String = "boss_01"
## Habilidad que se desbloquea al vencerlo ("" = ninguna). Se conecta en Fase 7.
@export var reward_ability: String = ""

@export_group("Daño y feedback")
@export var contact_damage: int = 1
## Apagar para jefes voladores.
@export var use_gravity: bool = true
@export var gravity: float = 980.0
@export var hit_flash_color: Color = Color(1, 1, 1)
@export var hit_flash_time: float = 0.06
@export var hit_hitstop: float = 0.04

var health: int
var phase: int = 1
var active: bool = false          # la arena lo activa al empezar la pelea
var is_dead: bool = false
var flash_timer: float = 0.0
var base_color: Color
var player: Node2D = null

@onready var body: ColorRect = $Body


func _ready() -> void:
	add_to_group("boss")
	health = max_health
	base_color = body.color
	_acquire_player()
	_on_boss_ready()
	health_changed.emit(health, max_health)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if player == null or not is_instance_valid(player):
		_acquire_player()
	_update_flash(delta)

	if use_gravity and not is_on_floor():
		velocity.y += gravity * delta

	if active:
		_boss_physics(delta)
	else:
		# Inactivo: quieto en el piso hasta que arranque la pelea.
		velocity.x = move_toward(velocity.x, 0.0, 600.0 * delta)

	move_and_slide()


# La arena llama esto cuando el player entra a pelear.
func activate() -> void:
	active = true


# La llama el ataque del player (hurtbox en grupo "enemy_hurtbox").
func take_damage(amount: int, from_position: Vector2) -> void:
	if is_dead:
		return
	health -= amount
	body.color = hit_flash_color
	flash_timer = hit_flash_time
	Juice.hitstop(hit_hitstop)
	Audio.play("boss_hit", 0.05)
	_check_phase()
	health_changed.emit(health, max_health)
	if health <= 0:
		_die()


func _check_phase() -> void:
	# Fase 2 al bajar de la mitad de la vida.
	if phase == 1 and health <= max_health / 2:
		phase = 2
		_on_phase_changed(2)


func _die() -> void:
	is_dead = true
	Audio.play("enemy_death")
	Juice.shake(9.0, 0.4)  # la caída del jefe se siente en la cámara
	for i in currency_drop:
		var coin := COIN_SCENE.instantiate()
		get_parent().add_child(coin)
		coin.global_position = global_position
	Game.mark_boss_defeated(boss_id)
	if reward_ability != "":
		Game.unlock_ability(reward_ability)
	defeated.emit()
	_on_defeated()
	queue_free()


func _update_flash(delta: float) -> void:
	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0:
			body.color = base_color


# Dirección hacia el player: -1 izquierda, 1 derecha.
func dir_to_player() -> int:
	if player == null:
		return 1
	return 1 if player.global_position.x > global_position.x else -1


# Distancia horizontal al player.
func dist_to_player() -> float:
	if player == null:
		return 0.0
	return absf(player.global_position.x - global_position.x)


func _acquire_player() -> void:
	player = get_tree().get_first_node_in_group("player")


# ---- "Virtuales": el jefe concreto los sobreescribe ----
func _on_boss_ready() -> void:
	pass

func _boss_physics(_delta: float) -> void:
	pass

func _on_phase_changed(_new_phase: int) -> void:
	pass

func _on_defeated() -> void:
	pass
