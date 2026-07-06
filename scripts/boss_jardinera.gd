extends "res://scripts/boss_base.gd"

# ============================================================
#  BOSS 04 — "LA JARDINERA" (Raíz)
#  La guardiana del árbol madre. No es enemiga: te está probando.
#  Patrones:
#   - EMBESTIDA: cruza la arena de un envión (telegrafiada).
#   - RAÍCES: brotan del suelo bajo tus pies (sombra de aviso).
#   - CURA: canaliza y se cura... salvo que la golpees (interrumpe).
#  AL "MORIR" NO MUERE: se arrodilla, te habla y te da LA SEMILLA.
# ============================================================

enum State { IDLE, TELEGRAPH, CHARGE, ROOTS, HEAL, KNEELING }

const ROOT_SCENE := preload("res://scenes/props/root_spike.tscn")

@export_group("Patrones")
@export var idle_time: float = 1.0
@export var telegraph_time: float = 0.55
@export var charge_speed: float = 380.0
@export var charge_time: float = 0.7
## Cuántas raíces brotan por tanda.
@export var root_count: int = 3
## Segundos entre raíz y raíz de la tanda.
@export var root_interval: float = 0.45
## Cuánto canaliza la cura (si nadie la corta).
@export var heal_channel_time: float = 2.2
## Vida que recupera si completa la cura.
@export var heal_amount: int = 4

@export_group("Colores")
@export var telegraph_color: Color = Color(1.0, 0.6, 0.2)
@export var heal_color: Color = Color(0.4, 0.9, 0.5)

var state: int = State.IDLE
var state_time: float = 0.0
var charge_dir: int = 1
var roots_left: int = 0
var root_timer: float = 0.0
var next_attack: int = 0  # rota entre embestida, raíces y (si le falta vida) cura


func _on_boss_ready() -> void:
	_enter_idle()


func _boss_physics(delta: float) -> void:
	if state == State.KNEELING:
		velocity.x = 0.0
		return
	state_time -= delta
	match state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0.0, 700.0 * delta)
			if state_time <= 0.0:
				_enter_telegraph()
		State.TELEGRAPH:
			velocity.x = move_toward(velocity.x, 0.0, 900.0 * delta)
			if state_time <= 0.0:
				_start_attack()
		State.CHARGE:
			velocity.x = charge_dir * (charge_speed if phase == 1 else charge_speed * 1.25)
			if state_time <= 0.0 or is_on_wall():
				_enter_idle()
		State.ROOTS:
			velocity.x = 0.0
			root_timer -= delta
			if root_timer <= 0.0 and roots_left > 0:
				_spawn_root()
				roots_left -= 1
				root_timer = root_interval
			if roots_left <= 0 and root_timer <= 0.0:
				_enter_idle()
		State.HEAL:
			velocity.x = 0.0
			body.color = heal_color
			if state_time <= 0.0:
				# Nadie la cortó: se cura.
				health = mini(health + heal_amount, max_health)
				health_changed.emit(health, max_health)
				_enter_idle()


func _enter_idle() -> void:
	state = State.IDLE
	state_time = idle_time if phase == 1 else idle_time * 0.65
	body.color = base_color


func _enter_telegraph() -> void:
	state = State.TELEGRAPH
	state_time = telegraph_time if phase == 1 else telegraph_time * 0.6
	charge_dir = dir_to_player()
	body.color = telegraph_color


func _start_attack() -> void:
	body.color = base_color
	# Rotación simple: embestida → raíces → (cura si está herida) → ...
	next_attack = (next_attack + 1) % 3
	if next_attack == 2 and health < max_health - heal_amount:
		state = State.HEAL
		state_time = heal_channel_time
	elif next_attack == 1:
		state = State.ROOTS
		roots_left = root_count if phase == 1 else root_count + 2
		root_timer = 0.0
	else:
		state = State.CHARGE
		state_time = charge_time
		charge_dir = dir_to_player()


func _spawn_root() -> void:
	if player == null:
		return
	var root := ROOT_SCENE.instantiate()
	get_parent().add_child(root)
	# Brota justo bajo el player, al nivel del piso de la arena.
	root.global_position = Vector2(player.global_position.x, 580.0)
	Audio.play("attack", 0.15)


# Golpearla durante la cura la interrumpe: la mecánica central.
func _on_hit() -> void:
	if state == State.HEAL:
		body.color = base_color
		_enter_idle()
		Juice.shake(3.0, 0.15)


# No muere: se arrodilla, entrega la Semilla y te habla.
func _should_free_on_death() -> bool:
	return false


func _on_defeated() -> void:
	state = State.KNEELING
	velocity = Vector2.ZERO
	body.color = Color(0.5, 0.55, 0.45)
	scale.y = 0.7  # arrodillada
	# Apagar el daño por contacto: ya no es una amenaza.
	$ContactDamage/CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	var dialogue = get_tree().get_first_node_in_group("dialogue")
	if dialogue != null:
		dialogue.show_dialogue("La Jardinera", [
			"Basta. Alcanza.",
			"Mordí al que vino antes que vos. A vos no hace falta.",
			"Entonces sos vos. Llevala donde duela más.",
		])
