extends "res://scripts/boss_base.gd"

# ============================================================
#  BOSS 01 — "Centinela"
#  Jefe melee simple, legible y telegrafiado. Dos ataques:
#   - CHARGE: embestida horizontal (si estás lejos).
#   - HOP: salto hacia vos (si estás cerca).
#  Antes de cada ataque hay un TELEGRAPH (cambia de color) para
#  que el golpe se vea venir. En fase 2 (mitad de vida) acelera.
# ============================================================

enum State { IDLE, TELEGRAPH, CHARGE, HOP }

@export_group("Ataques")
## Pausa entre ataques.
@export var idle_time: float = 0.9
## Cuánto dura el aviso (windup) antes de atacar.
@export var telegraph_time: float = 0.5
## Velocidad de la embestida.
@export var charge_speed: float = 360.0
## Cuánto dura la embestida.
@export var charge_time: float = 0.7
## Empuje horizontal del salto.
@export var hop_speed_x: float = 220.0
## Empuje vertical del salto.
@export var hop_speed_y: float = 480.0
## Distancia a partir de la cual elige embestida en vez de salto.
@export var charge_range: float = 220.0

@export_group("Colores")
@export var telegraph_color: Color = Color(1.0, 0.6, 0.2)
@export var phase2_color: Color = Color(0.7, 0.2, 0.25)

var state: int = State.IDLE
var state_time: float = 0.0
var charge_dir: int = 1


func _on_boss_ready() -> void:
	_enter_idle()


func _boss_physics(delta: float) -> void:
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
			var spd := charge_speed if phase == 1 else charge_speed * 1.3
			velocity.x = charge_dir * spd
			# Termina la embestida por tiempo o al chocar una pared.
			if state_time <= 0.0 or is_on_wall():
				_enter_idle()
		State.HOP:
			# En el aire; al aterrizar (tras un mínimo) vuelve a idle.
			if is_on_floor() and state_time <= 0.0:
				_enter_idle()


func _enter_idle() -> void:
	state = State.IDLE
	state_time = idle_time if phase == 1 else idle_time * 0.6
	body.color = base_color


func _enter_telegraph() -> void:
	state = State.TELEGRAPH
	state_time = telegraph_time if phase == 1 else telegraph_time * 0.55
	charge_dir = dir_to_player()
	body.color = telegraph_color   # windup: el jugador ve venir el golpe


func _start_attack() -> void:
	body.color = base_color
	# Lejos → embestida; cerca → salto encima.
	if dist_to_player() > charge_range:
		_start_charge()
	else:
		_start_hop()


func _start_charge() -> void:
	state = State.CHARGE
	state_time = charge_time
	charge_dir = dir_to_player()


func _start_hop() -> void:
	state = State.HOP
	state_time = 0.25  # mínimo en el aire antes de poder reevaluar
	velocity.y = -hop_speed_y
	velocity.x = dir_to_player() * hop_speed_x


func _on_phase_changed(new_phase: int) -> void:
	if new_phase == 2:
		# Tinte distinto para que se note el cambio de fase.
		base_color = phase2_color
		body.color = phase2_color
