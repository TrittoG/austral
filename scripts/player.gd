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

# ---- Valores derivados (no tocar a mano) -------------------
# Se calculan a partir de jump_height y los tiempos. Se recalculan cada
# frame para que tunear los @export de arriba surta efecto en vivo.
var jump_velocity: float
var jump_gravity: float
var fall_gravity: float

# ---- Contadores de asistencia ------------------------------
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0


func _ready() -> void:
	_update_jump_parameters()


func _physics_process(delta: float) -> void:
	# Recalcular salto/gravedad cada frame permite tunear desde el inspector
	# con el juego corriendo. Es barato y vale oro para iterar el feel.
	_update_jump_parameters()

	_update_assist_timers(delta)
	_try_jump()
	_apply_variable_jump_height()
	_apply_gravity(delta)
	_apply_horizontal_movement(delta)

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
		var accel := ground_acceleration if is_on_floor() else air_acceleration
		velocity.x = move_toward(velocity.x, direction * speed, accel * delta)
	else:
		var friction := ground_friction if is_on_floor() else air_friction
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
