extends CharacterBody2D

# ============================================================
#  PLAYER CONTROLLER — Metroidvania (game feel primero)
#  Referencia de feel: Hollow Knight.
#
#  Toda la lógica de física vive en _physics_process(delta).
#  Todos los parámetros son @export para tunearlos en vivo
#  desde el inspector con el juego corriendo.
# ============================================================

# ---- Movimiento horizontal ---------------------------------
@export_group("Movimiento horizontal")
## Velocidad máxima de corrida (px/s).
@export var speed: float = 200.0
## Aceleración en el suelo (px/s²). 2000 ≈ llegar a velocidad máx en ~0.1s.
@export var ground_acceleration: float = 2000.0
## Aceleración en el aire (px/s²). Arranca parejo al suelo y después se tunea
## (en el aire suele convenir un poco menos de control).
@export var air_acceleration: float = 2000.0
## Desaceleración al soltar en el suelo (px/s²).
@export var ground_friction: float = 2000.0
## Desaceleración al soltar en el aire (px/s²).
@export var air_friction: float = 2000.0

# ---- Salto (derivado de altura y tiempos) ------------------
@export_group("Salto")
## Qué tan alto sube el salto, en píxeles.
@export var jump_height: float = 80.0
## Segundos hasta el punto más alto (subida).
@export var jump_time_to_peak: float = 0.4
## Segundos de bajada. Más corto que la subida → mejor feel (gravedad asimétrica).
@export var jump_time_to_descent: float = 0.3
## Al soltar el botón mientras subís, se multiplica velocity.y por esto.
## Tap corto = salto bajo, mantener = salto alto.
@export_range(0.0, 1.0) var jump_cut_multiplier: float = 0.5

# ---- Asistencias de salto ----------------------------------
@export_group("Asistencias de salto")
## Ventana (s) para saltar después de caerte de un borde sin haber saltado.
@export var coyote_time: float = 0.1
## Ventana (s) para "recordar" un salto apretado antes de tocar el piso.
@export var jump_buffer_time: float = 0.1

# ---- Ataque (el "nail") ------------------------------------
@export_group("Ataque")
## Daño que hace cada golpe (no te enrosques con el número todavía).
@export var attack_damage: int = 1
## Cuántos segundos queda activo el hitbox del golpe.
@export var attack_duration: float = 0.12
## Tiempo mínimo entre golpes (cadencia del ataque).
@export var attack_cooldown: float = 0.25
## Alcance del golpe en píxeles (largo del hitbox).
@export var attack_reach: float = 50.0
## Ancho del hitbox del golpe.
@export var attack_width: float = 44.0
## Congelamiento del juego al impactar (hitstop). 0.05 ≈ 3 frames.
@export var attack_hitstop: float = 0.05

# ---- Pogo (rebote al pegar hacia abajo en el aire) ---------
@export_group("Pogo")
## Impulso hacia arriba al pegarle a algo con un golpe hacia abajo.
@export var pogo_velocity: float = 360.0

# ---- Vida y daño recibido ----------------------------------
@export_group("Vida")
## Vida máxima del player.
@export var max_health: int = 5
## Empuje horizontal al recibir un golpe.
@export var hurt_knockback: float = 250.0
## Empuje vertical (hacia arriba) al recibir un golpe.
@export var hurt_knockback_up: float = 140.0
## Segundos de invulnerabilidad tras recibir daño (i-frames).
@export var invuln_time: float = 1.0
## Hitstop al recibir daño (un poco más largo que el de pegar).
@export var hurt_hitstop: float = 0.08

# ---- Habilidades desbloqueadas (sistema de flags) ----------
# Cada habilidad arranca bloqueada y se activa con su flag. En la Fase 7
# estas empiezan en false y se prenden al conseguir la habilidad jugando.
# Por ahora arrancan en true para poder probarlas de una.
@export_group("Habilidades desbloqueadas")
@export var has_dash: bool = true

# ---- Dash --------------------------------------------------
@export_group("Dash")
## Velocidad del impulso del dash (px/s).
@export var dash_speed: float = 500.0
## Cuánto dura el dash en segundos.
@export var dash_duration: float = 0.15
## Tiempo mínimo entre dashes.
@export var dash_cooldown: float = 0.4
## Si está activo, sos invulnerable durante el dash (i-frames).
@export var dash_iframes: bool = false

# ---- Valores derivados (no tocar a mano) -------------------
# Se calculan a partir de jump_height y los tiempos. Se recalculan cada
# frame para que tunear los @export de arriba surta efecto en vivo.
var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

# ---- Contadores de asistencia ------------------------------
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# ---- Estado de combate y vida ------------------------------
var facing: int = 1                # 1 = mira a la derecha, -1 a la izquierda
var health: int                    # vida actual
var attack_cooldown_timer: float = 0.0   # tiempo hasta poder volver a pegar
var attack_active_timer: float = 0.0     # tiempo que queda el hitbox activo
var attack_dir: Vector2 = Vector2.RIGHT  # dirección del golpe en curso
var attack_hit_targets: Array = []       # a quién ya golpeó este swing (evita doble daño)
var invuln_timer: float = 0.0            # i-frames restantes
var spawn_point: Vector2                 # dónde reaparecer al morir (provisorio)

# ---- Estado del dash ---------------------------------------
var is_dashing: bool = false
var dash_timer: float = 0.0              # tiempo activo restante
var dash_cooldown_timer: float = 0.0     # tiempo hasta poder volver a dashear
var dash_dir: int = 1                    # dirección del dash en curso

# Se emite cuando cambia la vida, para que el HUD se actualice.
signal health_changed(current: int, maximum: int)

# ---- Referencias a nodos -----------------------------------
@onready var sword: Area2D = $Sword
@onready var sword_shape: CollisionShape2D = $Sword/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var body: ColorRect = $Body


func _ready() -> void:
	_update_jump_parameters()
	add_to_group("player")
	health = max_health
	spawn_point = global_position
	# El hitbox del golpe arranca apagado; se prende solo al atacar.
	sword_shape.disabled = true
	health_changed.emit(health, max_health)


func _physics_process(delta: float) -> void:
	# Recalcular salto/gravedad cada frame permite tunear desde el inspector
	# con el juego corriendo. Es barato y vale oro para iterar el feel.
	_update_jump_parameters()

	# El dash manda: mientras dura, ignora gravedad y control horizontal normal.
	_handle_dash(delta)
	if not is_dashing:
		_update_assist_timers(delta)
		_try_jump()
		_apply_variable_jump_height()
		_apply_gravity(delta)
		_apply_horizontal_movement(delta)

	_handle_attack(delta)
	_handle_invulnerability(delta)
	_check_incoming_damage()

	move_and_slide()


# ------------------------------------------------------------
#  SALTO DERIVADO + GRAVEDAD ASIMÉTRICA
# ------------------------------------------------------------
# En vez de tunear "velocidad de salto" y "gravedad" como números mágicos,
# pensamos en términos físicos: "quiero saltar 80px y llegar al pico en 0.4s".
# De ahí se derivan la velocidad inicial y las dos gravedades.
func _update_jump_parameters() -> void:
	jump_velocity = -(2.0 * jump_height) / jump_time_to_peak
	jump_gravity = (2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
	fall_gravity = (2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)


# Gravedad asimétrica: cae más rápido de lo que sube. Esto es clave para que
# el muñeco no se sienta "flotante". (Queda cubierto con descent < peak.)
# Nota: se llama get_current_gravity() y no get_gravity() porque este último
# ya existe en la clase base (devuelve Vector2) y sobreescribirlo da error.
func get_current_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func _apply_gravity(delta: float) -> void:
	velocity.y += get_current_gravity() * delta


# ------------------------------------------------------------
#  COYOTE TIME + JUMP BUFFERING
# ------------------------------------------------------------
func _update_assist_timers(delta: float) -> void:
	# Coyote: mientras pisás, el timer está "cargado" a tope. Al caerte de un
	# borde (sin saltar) empieza a descontar, dándote unos frames para saltar.
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Buffer: si apretás saltar antes de aterrizar, guardamos la intención
	# unos frames para ejecutarla apenas toques el piso. El salto nunca se
	# siente "comido".
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta


func _try_jump() -> void:
	# Salta si hay intención bufferizada Y todavía queda coyote disponible.
	# Consumimos ambos timers para que no se dispare dos veces.
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0


# ------------------------------------------------------------
#  ALTURA DE SALTO VARIABLE
# ------------------------------------------------------------
# Si soltás el botón mientras todavía subís, le cortamos el impulso.
# Es de las cosas que más se sienten: control fino sobre la altura.
func _apply_variable_jump_height() -> void:
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier


# ------------------------------------------------------------
#  MOVIMIENTO HORIZONTAL CON ACELERACIÓN Y FRICCIÓN
# ------------------------------------------------------------
# La velocidad no se setea de golpe: acelera hacia el objetivo y desacelera
# al soltar. Eso le da peso e inercia. Parámetros separados suelo/aire.
func _apply_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		facing = 1 if direction > 0.0 else -1  # recordar hacia dónde mira
		var accel := ground_acceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, direction * speed, accel * delta)
	else:
		var friction := ground_friction if is_on_floor() else air_friction
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)


# ------------------------------------------------------------
#  DASH (primera habilidad de movimiento)
# ------------------------------------------------------------
# Impulso horizontal rápido. Mientras dura, anula la gravedad y el control
# normal: vas derecho a velocidad fija. La velocidad y la duración son las
# que más cambian el feel, así que cada una es @export.
func _handle_dash(delta: float) -> void:
	dash_cooldown_timer = maxf(dash_cooldown_timer - delta, 0.0)

	# Iniciar dash: requiere tener la habilidad y no estar en cooldown.
	var can_dash := has_dash and dash_cooldown_timer <= 0.0 and not is_dashing
	if Input.is_action_just_pressed("dash") and can_dash:
		_start_dash()

	# Mientras el dash está activo, forzar la velocidad en la dirección fijada.
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_dir * dash_speed
		velocity.y = 0.0  # dash horizontal puro, sin caer
		if dash_timer <= 0.0:
			is_dashing = false


func _start_dash() -> void:
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	dash_dir = facing  # dashea hacia donde mira
	# i-frames opcionales durante el dash (cruzar proyectiles/enemigos).
	if dash_iframes:
		invuln_timer = maxf(invuln_timer, dash_duration)


# ------------------------------------------------------------
#  ATAQUE CUERPO A CUERPO (el "nail") + POGO
# ------------------------------------------------------------
# Un hitbox temporal que aparece unos frames en la dirección que mirás
# (o arriba/abajo si lo apuntás). El feel del golpe está en el feedback:
# hitstop al impactar, knockback y flash los pone quien recibe el golpe.
func _handle_attack(delta: float) -> void:
	attack_cooldown_timer = maxf(attack_cooldown_timer - delta, 0.0)

	# Iniciar un golpe nuevo si no hay cooldown pendiente.
	if Input.is_action_just_pressed("attack") and attack_cooldown_timer <= 0.0:
		_start_attack()

	# Mientras el hitbox está activo, chequear a quién toca.
	if attack_active_timer > 0.0:
		attack_active_timer -= delta
		_check_attack_hits()
		if attack_active_timer <= 0.0:
			sword_shape.set_deferred("disabled", true)


func _start_attack() -> void:
	attack_dir = _get_attack_direction()
	attack_active_timer = attack_duration
	attack_cooldown_timer = attack_cooldown
	attack_hit_targets.clear()
	_position_sword(attack_dir)
	sword_shape.disabled = false


# La dirección del golpe: arriba si apuntás arriba, abajo si apuntás abajo
# estando en el aire (el pogo solo tiene sentido en el aire), si no horizontal.
func _get_attack_direction() -> Vector2:
	if Input.is_action_pressed("look_up"):
		return Vector2.UP
	if Input.is_action_pressed("look_down") and not is_on_floor():
		return Vector2.DOWN
	return Vector2.RIGHT if facing >= 0 else Vector2.LEFT


# Coloca y orienta el hitbox del golpe según la dirección.
func _position_sword(dir: Vector2) -> void:
	var shape := sword_shape.shape as RectangleShape2D
	if dir == Vector2.UP or dir == Vector2.DOWN:
		shape.size = Vector2(attack_width, attack_reach)
	else:
		shape.size = Vector2(attack_reach, attack_width)
	# Desplazar el hitbox hacia afuera, en la dirección del golpe.
	sword_shape.position = dir * (attack_reach * 0.5 + 8.0)


func _check_attack_hits() -> void:
	for area in sword.get_overlapping_areas():
		if not area.is_in_group("enemy_hurtbox"):
			continue
		# Sin tipo explícito a propósito: take_damage no existe en Node,
		# así que un target tipado como Node daría error al llamarlo.
		var target = area.get_owner()
		if target == null:
			target = area.get_parent()
		if target in attack_hit_targets:
			continue
		attack_hit_targets.append(target)

		if target.has_method("take_damage"):
			target.take_damage(attack_damage, global_position)

		Juice.hitstop(attack_hitstop)

		# Pogo: si el golpe es hacia abajo y conectó, rebotamos hacia arriba.
		if attack_dir == Vector2.DOWN:
			velocity.y = -pogo_velocity
			# refrescar coyote para poder encadenar un salto tras el pogo
			coyote_timer = coyote_time


# ------------------------------------------------------------
#  VIDA, DAÑO E I-FRAMES
# ------------------------------------------------------------
func _handle_invulnerability(delta: float) -> void:
	if invuln_timer > 0.0:
		invuln_timer -= delta
		# Parpadeo: prende/apaga el cuerpo varias veces por segundo.
		body.visible = int(invuln_timer * 20.0) % 2 == 0
		if invuln_timer <= 0.0:
			body.visible = true


# Revisa si algún hitbox enemigo está tocando nuestro hurtbox.
func _check_incoming_damage() -> void:
	if invuln_timer > 0.0:
		return
	for area in hurtbox.get_overlapping_areas():
		if area.is_in_group("enemy_hitbox"):
			_take_damage(1, area.global_position)
			break


func _take_damage(amount: int, from_position: Vector2) -> void:
	if invuln_timer > 0.0:
		return
	health -= amount
	invuln_timer = invuln_time

	# Knockback en sentido contrario a la fuente del daño.
	var dir := signf(global_position.x - from_position.x)
	if dir == 0.0:
		dir = -facing
	velocity.x = dir * hurt_knockback
	velocity.y = -hurt_knockback_up

	Juice.hitstop(hurt_hitstop)
	health_changed.emit(health, max_health)

	if health <= 0:
		_die()


# Provisorio hasta la Fase 5 (checkpoints): reaparece en el punto inicial.
func _die() -> void:
	health = max_health
	global_position = spawn_point
	velocity = Vector2.ZERO
	invuln_timer = invuln_time
	health_changed.emit(health, max_health)
