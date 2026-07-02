extends "res://scripts/boss_base.gd"

# ============================================================
#  BOSS 02 — "Espectro del Abismo"
#  Jefe volador. Flota sobre vos y alterna dos ataques
#  telegrafiados:
#   - SWOOP: picada en diagonal hacia tu posición (si estás cerca).
#   - VOLLEY: ráfaga de proyectiles apuntados con apertura.
#  En fase 2 (mitad de vida) acelera y tira más proyectiles.
#  Vulnerable siempre; la picada baja lo deja a tiro (y admite pogo).
# ============================================================

enum State { HOVER, TELEGRAPH, SWOOP, RISE }

@export_group("Vuelo")
## Qué tan alto flota por encima del player.
@export var hover_height: float = 170.0
## Ganancia del flotado (más alto = te sigue más rígido).
@export var hover_gain: float = 2.2
## Amplitud del vaivén al flotar.
@export var bob_amplitude: float = 16.0
@export var bob_speed: float = 3.0

@export_group("Ataques")
## Pausa entre ataques.
@export var attack_interval: float = 1.5
## Duración del aviso antes de atacar.
@export var telegraph_time: float = 0.55
## Velocidad de la picada.
@export var swoop_speed: float = 430.0
## Distancia por debajo de la cual prefiere la picada.
@export var swoop_range: float = 240.0
## Proyectiles por ráfaga (fase 2 suma 2).
@export var volley_count: int = 3
@export var projectile_speed: float = 250.0
@export var projectile_scene: PackedScene

@export_group("Colores")
@export var telegraph_color: Color = Color(1.0, 0.6, 0.2)
@export var phase2_color: Color = Color(0.75, 0.3, 0.6)

var state: int = State.HOVER
var state_time: float = 0.0
var swoop_dir: Vector2 = Vector2.DOWN
var wants_swoop: bool = false
var time: float = 0.0


func _on_boss_ready() -> void:
	_enter_hover()


func _boss_physics(delta: float) -> void:
	time += delta
	state_time -= delta
	match state:
		State.HOVER:
			_hover(delta)
			if state_time <= 0.0:
				_enter_telegraph()
		State.TELEGRAPH:
			velocity = velocity.move_toward(Vector2.ZERO, 800.0 * delta)
			if state_time <= 0.0:
				_attack()
		State.SWOOP:
			velocity = swoop_dir * (swoop_speed if phase == 1 else swoop_speed * 1.25)
			if is_on_floor() or state_time <= 0.0:
				state = State.RISE
				state_time = 0.6
		State.RISE:
			velocity = velocity.move_toward(Vector2(0, -220), 900.0 * delta)
			if state_time <= 0.0:
				_enter_hover()


# Flota hacia un punto por encima del player, con vaivén.
func _hover(_delta: float) -> void:
	if player == null:
		return
	var target: Vector2 = player.global_position + Vector2(0, -hover_height)
	target.y += sin(time * bob_speed) * bob_amplitude
	# Con tope de velocidad: si quedó lejos, persigue pero no se teletransporta.
	velocity = ((target - global_position) * hover_gain).limit_length(340.0)


func _enter_hover() -> void:
	state = State.HOVER
	state_time = attack_interval if phase == 1 else attack_interval * 0.65
	body.color = base_color


func _enter_telegraph() -> void:
	state = State.TELEGRAPH
	state_time = telegraph_time if phase == 1 else telegraph_time * 0.6
	body.color = telegraph_color  # el aviso: se ve venir el ataque
	# Elegir ataque ya, para fijar la intención: cerca → picada.
	wants_swoop = dist_to_player() < swoop_range or randf() < 0.3


func _attack() -> void:
	body.color = base_color
	if wants_swoop and player != null:
		swoop_dir = (player.global_position - global_position).normalized()
		state = State.SWOOP
		state_time = 0.7
	else:
		_fire_volley()
		_enter_hover()


# Ráfaga apuntada con apertura en abanico.
func _fire_volley() -> void:
	if projectile_scene == null or player == null:
		return
	var count := volley_count if phase == 1 else volley_count + 2
	var base_angle: float = (player.global_position - global_position).angle()
	var spread := 0.5  # apertura total en radianes
	for i in count:
		var t := 0.0 if count == 1 else float(i) / float(count - 1) - 0.5
		var angle := base_angle + t * spread
		var proj = projectile_scene.instantiate()
		get_parent().add_child(proj)
		proj.global_position = global_position
		if proj.has_method("setup_vector"):
			proj.setup_vector(Vector2.from_angle(angle) * projectile_speed)
	Audio.play("shoot", 0.1)


func _on_phase_changed(new_phase: int) -> void:
	if new_phase == 2:
		base_color = phase2_color
		body.color = phase2_color
