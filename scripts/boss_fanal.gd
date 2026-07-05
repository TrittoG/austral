extends "res://scripts/boss_base.gd"

# ============================================================
#  BOSS 03 — "EL FANAL" (El Velo)
#  Criatura abisal casi invisible en la niebla: solo su LINTERNA
#  se ve bien. La luz ES la telegrafía: cuando brilla fuerte,
#  viene el ataque. El jugador aprende a leer la luz, no al bicho.
#   - EMBESTIDA: se lanza hacia vos (cerca).
#   - ESCUPITAJO: ráfaga de proyectiles apuntados (lejos).
#  Fase 2: más rápido, más proyectiles. Al caer suelta el
#  DISIPADOR IÓNICO (y la niebla del Velo se levanta al instante).
# ============================================================

enum State { LURK, TELEGRAPH, LUNGE, RISE }

@export_group("Acecho")
## Transparencia del cuerpo mientras acecha (0.15 = casi invisible).
@export_range(0.0, 1.0) var lurk_alpha: float = 0.22
## Velocidad de deriva hacia el player mientras acecha.
@export var lurk_speed: float = 110.0
## Altura a la que flota respecto al player.
@export var hover_height: float = 120.0

@export_group("Ataques")
@export var attack_interval: float = 1.7
@export var telegraph_time: float = 0.7
@export var lunge_speed: float = 470.0
## Distancia por debajo de la cual embiste en vez de escupir.
@export var lunge_range: float = 260.0
@export var volley_count: int = 3
@export var projectile_speed: float = 240.0
@export var projectile_scene: PackedScene

var state: int = State.LURK
var state_time: float = 0.0
var lunge_dir: Vector2 = Vector2.DOWN
var wants_lunge: bool = false
var target_alpha: float = 1.0
var time: float = 0.0

@onready var lantern: Polygon2D = $Lantern


func _on_boss_ready() -> void:
	_enter_lurk()


func _boss_physics(delta: float) -> void:
	time += delta
	state_time -= delta

	# La visibilidad sigue al estado: tenue al acechar, plena al atacar.
	modulate.a = lerpf(modulate.a, target_alpha, 6.0 * delta)
	# La linterna palpita siempre (es lo único que se ve en la niebla).
	lantern.scale = Vector2.ONE * (1.0 + 0.15 * sin(time * 5.0))

	match state:
		State.LURK:
			_drift(delta)
			if state_time <= 0.0:
				_enter_telegraph()
		State.TELEGRAPH:
			velocity = velocity.move_toward(Vector2.ZERO, 700.0 * delta)
			if state_time <= 0.0:
				_attack()
		State.LUNGE:
			velocity = lunge_dir * (lunge_speed if phase == 1 else lunge_speed * 1.25)
			if is_on_floor() or state_time <= 0.0:
				state = State.RISE
				state_time = 0.55
		State.RISE:
			velocity = velocity.move_toward(Vector2(0, -200), 800.0 * delta)
			if state_time <= 0.0:
				_enter_lurk()


func _drift(_delta: float) -> void:
	if player == null:
		return
	var target: Vector2 = player.global_position + Vector2(0, -hover_height)
	target.y += sin(time * 2.2) * 20.0
	velocity = ((target - global_position) * 1.6).limit_length(lurk_speed)


func _enter_lurk() -> void:
	state = State.LURK
	state_time = attack_interval if phase == 1 else attack_interval * 0.6
	target_alpha = lurk_alpha
	body.color = base_color


func _enter_telegraph() -> void:
	state = State.TELEGRAPH
	state_time = telegraph_time if phase == 1 else telegraph_time * 0.65
	target_alpha = 1.0  # LA LUZ: se enciende → viene el golpe
	wants_lunge = dist_to_player() < lunge_range or randf() < 0.25


func _attack() -> void:
	if wants_lunge and player != null:
		lunge_dir = (player.global_position - global_position).normalized()
		state = State.LUNGE
		state_time = 0.65
	else:
		_fire_volley()
		_enter_lurk()


func _fire_volley() -> void:
	if projectile_scene == null or player == null:
		return
	var count := volley_count if phase == 1 else volley_count + 2
	var base_angle: float = (player.global_position - global_position).angle()
	for i in count:
		var t := 0.0 if count == 1 else float(i) / float(count - 1) - 0.5
		var proj = projectile_scene.instantiate()
		get_parent().add_child(proj)
		proj.global_position = global_position
		if proj.has_method("setup_vector"):
			proj.setup_vector(Vector2.from_angle(base_angle + t * 0.45) * projectile_speed)
	Audio.play("shoot", 0.1)


func _on_phase_changed(new_phase: int) -> void:
	if new_phase == 2:
		base_color = Color(0.75, 0.45, 0.3)
		body.color = base_color
