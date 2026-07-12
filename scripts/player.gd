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
## Velocidad terminal de caída (px/s). Evita caídas infinitamente rápidas
## en pozos largos y mantiene la caída legible.
@export var max_fall_speed: float = 520.0

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
# Los flags se leen del estado del juego (Game): arrancan bloqueados y se
# consiguen jugando. Con use_saved_abilities = false el player ignora el
# save y usa los flags del inspector (para test_room / pruebas aisladas).
@export_group("Habilidades desbloqueadas")
@export var use_saved_abilities: bool = true
@export var has_dash: bool = true

# ---- Dash --------------------------------------------------
@export_group("Dash")
## Velocidad del impulso del dash (px/s).
## 650 × 0.18s ≈ 117px de recorrido: salto+dash cruza ~250px,
## lo justo para el gap de 220px de La Grieta (imposible sin dash).
@export var dash_speed: float = 650.0
## Cuánto dura el dash en segundos.
@export var dash_duration: float = 0.18
## Tiempo mínimo entre dashes.
@export var dash_cooldown: float = 0.4
## Si está activo, sos invulnerable durante el dash (i-frames).
@export var dash_iframes: bool = false

# ---- Doble salto -------------------------------------------
@export_group("Doble salto")
@export var has_double_jump: bool = true
## Cuántos saltos extra en el aire (1 = doble salto).
@export var max_air_jumps: int = 1
## Altura del salto aéreo relativa al salto base (1.0 = misma altura).
@export var double_jump_height_mult: float = 1.0

# ---- Wall slide / wall jump --------------------------------
@export_group("Wall slide / wall jump")
@export var has_wall_jump: bool = true
## Velocidad de caída máxima mientras te deslizás por la pared (px/s).
@export var wall_slide_speed: float = 60.0
## Empuje horizontal al saltar de la pared (lejos de ella).
@export var wall_jump_velocity_x: float = 260.0
## Altura del wall jump relativa al salto base (1.0 = misma altura).
@export var wall_jump_height_mult: float = 1.0
## Tiempo (s) que se ignora el input horizontal tras un wall jump, para
## que el empuje te despegue de la pared aunque sigas apretando hacia ella.
@export var wall_jump_lockout: float = 0.12

# ---- Valores derivados (no tocar a mano) -------------------
# Se calculan a partir de jump_height y los tiempos. Se recalculan cada
# frame para que tunear los @export de arriba surta efecto en vivo.
var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

# ---- Contadores de asistencia ------------------------------
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_grounded: bool = false   # para detectar el aterrizaje (sonido)

# ---- Estado de combate y vida ------------------------------
var facing: int = 1                # 1 = mira a la derecha, -1 a la izquierda
var health: int                    # vida actual
var attack_cooldown_timer: float = 0.0   # tiempo hasta poder volver a pegar
var attack_active_timer: float = 0.0     # tiempo que queda el hitbox activo
var attack_dir: Vector2 = Vector2.RIGHT  # dirección del golpe en curso
var attack_hit_targets: Array = []       # a quién ya golpeó este swing (evita doble daño)
var invuln_timer: float = 0.0            # i-frames restantes
var spawn_point: Vector2                 # dónde reaparecer al morir (provisorio)

# ---- Último piso seguro (respawn de pinchos, estilo HK) -----
# Al tocar un hazard de terreno (grupo hazard_respawn) volvés acá.
var last_safe_position: Vector2
var _safe_ground_timer: float = 0.0

# ---- Estado del dash ---------------------------------------
var is_dashing: bool = false
var dash_timer: float = 0.0              # tiempo activo restante
var dash_cooldown_timer: float = 0.0     # tiempo hasta poder volver a dashear
var dash_dir: int = 1                    # dirección del dash en curso
var air_dashes_used: int = 0             # dashes aéreos desde el último piso/pared

# ---- Estado de doble salto y wall slide --------------------
var air_jumps_used: int = 0              # saltos aéreos consumidos desde el último piso/pared
var is_wall_sliding: bool = false        # true mientras te deslizás por una pared
var wall_dir: int = 0                    # hacia dónde está la pared: -1 izq, 1 der
var wall_jump_lockout_timer: float = 0.0 # ignora input horizontal mientras > 0

# ---- Modificadores por amuletos (los recalcula apply_charms) --
var charm_dash_cooldown_mult: float = 1.0
var charm_reach_mult: float = 1.0

# ---- Corrientes ascendentes (géiseres del Velo) ------------
# Lo setean las áreas updraft al entrar/salir. Empuja hacia arriba.
var updraft_force: float = 0.0

# ---- Savia Espesa (regeneración quieto) --------------------
var _still_time: float = 0.0

# ---- Modo dios (F1, solo builds de desarrollo) --------------
# Invulnerable + daño x5 + todas las habilidades. Para testear
# zonas sin pelear cada tramo. En el export final queda apagado
# (OS.is_debug_build()).
var god_mode: bool = false

# Se emite cuando cambia la vida, para que el HUD se actualice.
signal health_changed(current: int, maximum: int)

# ---- Referencias a nodos -----------------------------------
@onready var sword: Area2D = $Sword
@onready var sword_shape: CollisionShape2D = $Sword/CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var body: AnimatedSprite2D = $Body
@onready var slash_fx: Polygon2D = $SlashFX
@onready var dust_land: CPUParticles2D = $DustLand
@onready var dust_dash: CPUParticles2D = $DustDash
@onready var hit_sparks: CPUParticles2D = $HitSparks


func _ready() -> void:
	_update_jump_parameters()
	add_to_group("player")
	_apply_saved_state()
	spawn_point = global_position
	last_safe_position = global_position
	# El hitbox del golpe arranca apagado; se prende solo al atacar.
	sword_shape.disabled = true
	health_changed.emit(health, max_health)


# Toma del estado del juego la vida máxima y qué habilidades están
# desbloqueadas. Así el save manda sobre lo que se ve en el inspector.
func _apply_saved_state() -> void:
	max_health = Game.max_health
	health = max_health
	if use_saved_abilities:
		refresh_abilities()
		apply_charms()
		# Al desbloquear una habilidad (jefe, pickup) el player se entera solo,
		# y al cambiar amuletos en un banco recalcula sus stats.
		Game.ability_unlocked.connect(_on_ability_unlocked)
		Game.charms_changed.connect(apply_charms)


# ------------------------------------------------------------
#  AMULETOS — efectos sobre el player
# ------------------------------------------------------------
# Recalcula los modificadores según lo equipado. Acá se define QUÉ hace
# cada amuleto (el registro con nombre/costo vive en Game.CHARMS).
func apply_charms() -> void:
	charm_dash_cooldown_mult = 0.5 if Game.is_charm_equipped("garra_veloz") else 1.0
	charm_reach_mult = 1.4 if Game.is_charm_equipped("filo_largo") else 1.0

	# Corazón Férreo: +2 de vida máxima mientras esté puesto.
	var bonus := 2 if Game.is_charm_equipped("corazon_ferreo") else 0
	max_health = Game.max_health + bonus
	health = mini(health, max_health)  # sacarlo no cura, recorta
	health_changed.emit(health, max_health)


# Copia los flags de habilidad desde el estado del juego.
func refresh_abilities() -> void:
	has_dash = Game.get_ability("dash")
	has_double_jump = Game.get_ability("double_jump")
	has_wall_jump = Game.get_ability("wall_jump")


func _on_ability_unlocked(_key: String) -> void:
	refresh_abilities()


# ------------------------------------------------------------
#  MODO DIOS (F1, testing)
# ------------------------------------------------------------
func _toggle_god_mode() -> void:
	god_mode = not god_mode
	if god_mode:
		body.modulate = Color(1.6, 1.35, 0.7)  # tinte dorado: se nota que está activo
		has_dash = true
		has_double_jump = true
		has_wall_jump = true
	else:
		body.modulate = Color.WHITE
		refresh_abilities()  # vuelve a lo que dice el save
	var hud = get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("notify"):
		hud.notify("MODO DIOS: %s" % ("ON — invulnerable, daño x5" if god_mode else "OFF"))


# Restaura la vida al máximo (la usa el banco / checkpoint).
func full_heal() -> void:
	health = max_health
	health_changed.emit(health, max_health)


func _physics_process(delta: float) -> void:
	# Recalcular salto/gravedad cada frame permite tunear desde el inspector
	# con el juego corriendo. Es barato y vale oro para iterar el feel.
	_update_jump_parameters()

	if OS.is_debug_build() and Input.is_action_just_pressed("debug_god"):
		_toggle_god_mode()

	# El dash manda: mientras dura, ignora gravedad y control horizontal normal.
	_handle_dash(delta)
	if not is_dashing:
		_update_assist_timers(delta)
		_detect_wall_slide()        # decide si estamos deslizando (antes del salto)
		_try_jump()                 # salto de piso/coyote, wall jump o doble salto
		_apply_variable_jump_height()
		_apply_gravity(delta)
		_apply_wall_slide_clamp()   # limita la caída pegado a la pared (tras la gravedad)
		_apply_horizontal_movement(delta)

	_handle_attack(delta)
	_handle_invulnerability(delta)
	_check_incoming_damage()

	move_and_slide()
	_check_landing()
	_update_squash_stretch(delta)
	_update_sap_regen(delta)
	_update_animation()
	_track_safe_ground(delta)


# Memoriza dónde pisaste firme por última vez: si llevás un ratito
# parado en el piso (y no dasheando), este lugar es "seguro".
func _track_safe_ground(delta: float) -> void:
	if is_on_floor() and not is_dashing:
		_safe_ground_timer += delta
		if _safe_ground_timer >= 0.2:
			last_safe_position = global_position
	else:
		_safe_ground_timer = 0.0


# Elige la animación según el estado (y espeja el sprite al mirar
# a la izquierda). El dibujo lo pone el arte; la lógica va acá.
func _update_animation() -> void:
	body.flip_h = facing < 0
	var next := "idle"
	if attack_active_timer > 0.0:
		next = "attack"  # la estocada manda mientras el golpe está activo
	elif not is_on_floor():
		next = "jump" if velocity.y < 0.0 else "fall"
	elif absf(velocity.x) > 10.0:
		next = "run"
	if body.animation != next:
		body.play(next)


# Savia Espesa: quieto en el piso 4 segundos → +1 HP. Lento pero fiel.
func _update_sap_regen(delta: float) -> void:
	var resting := is_on_floor() and absf(velocity.x) < 5.0 and health < max_health
	if resting and Game.is_charm_equipped("savia_espesa"):
		_still_time += delta
		if _still_time >= 4.0:
			_still_time = 0.0
			health += 1
			health_changed.emit(health, max_health)
			Audio.play("checkpoint", 0.0, -12.0)
	else:
		_still_time = 0.0


# Sonido, polvo y squash al aterrizar (transición aire → piso).
func _check_landing() -> void:
	var grounded := is_on_floor()
	if grounded and not was_grounded:
		Audio.play("land", 0.1)
		dust_land.restart()
		body.scale = Vector2(1.3, 0.7)  # achatado al caer
	was_grounded = grounded


# ------------------------------------------------------------
#  SQUASH & STRETCH
# ------------------------------------------------------------
# Deformamos solo el ColorRect (la colisión no cambia): estirado al
# saltar, achatado al aterrizar, y vuelve solo a la forma normal.
func _update_squash_stretch(delta: float) -> void:
	body.scale = body.scale.lerp(Vector2.ONE, 12.0 * delta)


func _squash_jump() -> void:
	body.scale = Vector2(0.75, 1.25)  # estirado hacia arriba


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
	velocity.y = minf(velocity.y, max_fall_speed)  # velocidad terminal
	# Géiser: empuje hacia arriba, con tope de velocidad de ascenso.
	if updraft_force > 0.0:
		velocity.y -= updraft_force * delta
		velocity.y = maxf(velocity.y, -450.0)


# ------------------------------------------------------------
#  COYOTE TIME + JUMP BUFFERING
# ------------------------------------------------------------
func _update_assist_timers(delta: float) -> void:
	# Coyote: mientras pisás, el timer está "cargado" a tope. Al caerte de un
	# borde (sin saltar) empieza a descontar, dándote unos frames para saltar.
	if is_on_floor():
		coyote_timer = coyote_time
		air_jumps_used = 0    # tocar el piso recarga el doble salto
		air_dashes_used = 0   # ...y el dash aéreo
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
	# Sin intención de salto bufferizada no hay nada que hacer.
	if jump_buffer_timer <= 0.0:
		return

	# 1) Salto desde piso o coyote: la prioridad más alta.
	if coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		Audio.play("jump", 0.05)
		_squash_jump()
		return

	# 2) Wall jump: si estamos deslizando, saltamos lejos de la pared.
	if is_wall_sliding:
		velocity.y = jump_velocity * wall_jump_height_mult
		velocity.x = -wall_dir * wall_jump_velocity_x
		wall_jump_lockout_timer = wall_jump_lockout
		is_wall_sliding = false
		air_jumps_used = 0  # el wall jump también recarga el doble salto
		jump_buffer_timer = 0.0
		Audio.play("jump", 0.05)
		_squash_jump()
		return

	# 3) Doble salto: en el aire, si todavía quedan saltos aéreos.
	# Solo con el botón apretado ESTE frame (no bufferizado): así un salto
	# apretado justo antes de aterrizar espera al piso en vez de gastar
	# el salto aéreo a un pelo del suelo.
	var can_air_jump := has_double_jump and air_jumps_used < max_air_jumps
	if can_air_jump and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity * double_jump_height_mult
		air_jumps_used += 1
		jump_buffer_timer = 0.0
		Audio.play("jump", 0.08)
		_squash_jump()


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
	# Tras un wall jump, ignoramos el input unos frames para que el empuje
	# despegue de la pared aunque sigas apretando hacia ella.
	if wall_jump_lockout_timer > 0.0:
		wall_jump_lockout_timer -= delta
		return

	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		facing = 1 if direction > 0.0 else -1  # recordar hacia dónde mira
		var accel := ground_acceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, direction * speed, accel * delta)
	else:
		var friction := ground_friction if is_on_floor() else air_friction
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)


# ------------------------------------------------------------
#  WALL SLIDE + WALL JUMP
# ------------------------------------------------------------
# Deslizar: si te apretás contra una pared en el aire mientras caés, frenás
# la caída. El salto desde ahí (wall jump) lo maneja _try_jump.
func _detect_wall_slide() -> void:
	is_wall_sliding = false
	if not has_wall_jump or is_on_floor() or not is_on_wall():
		return

	var normal := get_wall_normal()
	if is_zero_approx(normal.x):
		return
	# La normal apunta hacia afuera de la pared. Si apunta a la derecha (+x),
	# la pared está a la izquierda → wall_dir = -1, y viceversa.
	wall_dir = -1 if normal.x > 0.0 else 1

	# Solo deslizamos si empujás hacia la pared y estás cayendo (no subiendo).
	var direction := Input.get_axis("move_left", "move_right")
	var pushing_into_wall := direction != 0.0 and (direction > 0.0) == (wall_dir > 0)
	if pushing_into_wall and velocity.y >= 0.0:
		is_wall_sliding = true
		air_jumps_used = 0    # agarrarte de la pared recarga el doble salto
		air_dashes_used = 0   # ...y el dash aéreo


# Limita la velocidad de caída mientras deslizás. Va DESPUÉS de la gravedad
# para que el clamp no se "pise" con la aceleración de caída del frame.
func _apply_wall_slide_clamp() -> void:
	if is_wall_sliding:
		velocity.y = minf(velocity.y, wall_slide_speed)


# ------------------------------------------------------------
#  DASH (primera habilidad de movimiento)
# ------------------------------------------------------------
# Impulso horizontal rápido. Mientras dura, anula la gravedad y el control
# normal: vas derecho a velocidad fija. La velocidad y la duración son las
# que más cambian el feel, así que cada una es @export.
func _handle_dash(delta: float) -> void:
	dash_cooldown_timer = maxf(dash_cooldown_timer - delta, 0.0)

	# Iniciar dash: habilidad + sin cooldown + (en el piso, o con dashes
	# aéreos disponibles: 1 normal, 2 con Doble Impulso, ∞ en modo dios).
	var can_dash := has_dash and dash_cooldown_timer <= 0.0 and not is_dashing
	if not is_on_floor() and air_dashes_used >= _max_air_dashes():
		can_dash = false
	if Input.is_action_just_pressed("dash") and can_dash:
		_start_dash()

	# Mientras el dash está activo, forzar la velocidad en la dirección fijada.
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_dir * dash_speed
		velocity.y = 0.0  # dash horizontal puro, sin caer
		if dash_timer <= 0.0:
			is_dashing = false


# Cuántos dashes se pueden encadenar en el aire.
func _max_air_dashes() -> int:
	if god_mode:
		return 99
	if Game.is_charm_equipped("doble_impulso"):
		return 2
	return 1


func _start_dash() -> void:
	is_dashing = true
	dash_timer = dash_duration
	if not is_on_floor():
		air_dashes_used += 1
	# Garra Veloz reduce el cooldown a la mitad.
	dash_cooldown_timer = dash_cooldown * charm_dash_cooldown_mult
	dash_dir = facing  # dashea hacia donde mira
	Audio.play("dash", 0.05)
	# Polvo hacia atrás y cuerpo estirado horizontal.
	dust_dash.direction = Vector2(-dash_dir, 0)
	dust_dash.restart()
	body.scale = Vector2(1.35, 0.7)
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
		# El tajo visible se desvanece con la duración del golpe.
		slash_fx.modulate.a = attack_active_timer / attack_duration
		if attack_active_timer <= 0.0:
			sword_shape.set_deferred("disabled", true)
			slash_fx.visible = false


func _start_attack() -> void:
	attack_dir = _get_attack_direction()
	attack_active_timer = attack_duration
	attack_cooldown_timer = attack_cooldown
	attack_hit_targets.clear()
	_position_sword(attack_dir)
	sword_shape.disabled = false
	# El tajo visible: apunta y se coloca en la dirección del golpe.
	slash_fx.rotation = attack_dir.angle()
	slash_fx.position = attack_dir * (attack_reach * charm_reach_mult * 0.5 + 8.0)
	slash_fx.modulate.a = 1.0
	slash_fx.visible = true
	Audio.play("attack", 0.06)


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
	# Filo Largo estira el alcance del golpe.
	var reach := attack_reach * charm_reach_mult
	var shape := sword_shape.shape as RectangleShape2D
	if dir == Vector2.UP or dir == Vector2.DOWN:
		shape.size = Vector2(attack_width, reach)
	else:
		shape.size = Vector2(reach, attack_width)
	# Desplazar el hitbox hacia afuera, en la dirección del golpe.
	sword_shape.position = dir * (reach * 0.5 + 8.0)


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
			var dmg := attack_damage * (5 if god_mode else 1)
			target.take_damage(dmg, global_position)

		Juice.hitstop(attack_hitstop)
		Juice.shake(2.0, 0.12)  # sutil: es un golpe que conecta
		Audio.play("hit", 0.1)
		# Chispas en el punto del impacto.
		if target is Node2D:
			hit_sparks.global_position = target.global_position
			hit_sparks.restart()

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
			if area.is_in_group("hazard_respawn") and not god_mode:
				_hazard_hit(area)
			else:
				_take_damage(_damage_from(area), area.global_position)
			break


# Pinchos/ácido estilo Hollow Knight: dañan Y te devuelven al último
# piso seguro (con un flash), en vez de solo empujarte.
func _hazard_hit(area: Area2D) -> void:
	_take_damage(_damage_from(area), area.global_position)
	if health <= 0:
		return  # la muerte ya te llevó al checkpoint
	global_position = last_safe_position
	velocity = Vector2.ZERO
	_safe_ground_timer = 0.0
	var manager = get_tree().get_first_node_in_group("rooms")
	if manager != null and manager.has_method("hazard_flash"):
		manager.hazard_flash()


# Cuánto daño hace una fuente de daño. Si el dueño del área (el enemigo)
# tiene contact_damage, usa ese; si no (hazards, proyectiles), 1 por defecto.
func _damage_from(area: Area2D) -> int:
	var src = area.get_owner()
	if src != null and "contact_damage" in src:
		return src.contact_damage
	return 1


func _take_damage(amount: int, from_position: Vector2) -> void:
	if god_mode or invuln_timer > 0.0:
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
	Juice.shake(6.0, 0.25)  # recibir daño sacude más que pegar
	Audio.play("hurt")
	health_changed.emit(health, max_health)

	if health <= 0:
		_die()


# Al morir, reaparece en el último checkpoint vía el RoomManager. Si no hay
# manager (ej: probando en test_room en aislado), respawn local al inicio.
func _die() -> void:
	var manager = get_tree().get_first_node_in_group("rooms")
	if manager != null and manager.has_method("respawn_at_checkpoint"):
		# Tu antimateria queda tirada donde caíste (la guarda una sombra).
		if "current_room_path" in manager:
			Game.drop_currency_at(manager.current_room_path, global_position)
		manager.respawn_at_checkpoint()
	else:
		full_heal()
		global_position = spawn_point
		velocity = Vector2.ZERO
		invuln_timer = invuln_time
