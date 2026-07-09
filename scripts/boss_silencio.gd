extends "res://scripts/boss_base.gd"

# ============================================================
#  JEFE FINAL — "EL SILENCIO"
#  Un agujero con forma. Tres fases:
#   1. EL HAMBRE  (vida > 2/3): barridos horizontales telegrafiados
#      + esporas de sombra apuntadas.
#   2. EL ROBO    (vida 1/3..2/3): TE COME EL DASH y lo usa contra
#      vos (embestidas rapidísimas). Lo recuperás al empujarlo a fase 3
#      (o al morir: el respawn te lo devuelve).
#   3. EL SILENCIO (vida < 1/3): la música muere, la sala se oscurece.
#      Ataques lentos y pesados. Terminarlo es apagar una vela.
#  Al caer: fundido al final (normal o verdadero según la Semilla).
# ============================================================

enum State { HOVER, TELEGRAPH, SWEEP, VOLLEY_RECOVER }

@export_group("Pelea")
@export var attack_interval: float = 1.4
@export var telegraph_time: float = 0.6
@export var sweep_speed: float = 460.0
@export var volley_count: int = 4
@export var projectile_speed: float = 230.0
@export var projectile_scene: PackedScene

var state: int = State.HOVER
var state_time: float = 0.0
var sweep_dir: Vector2 = Vector2.LEFT
var wants_sweep: bool = true
var time: float = 0.0
var stole_dash: bool = false
var ending_started: bool = false

@onready var aura: Polygon2D = $Aura


func _on_boss_ready() -> void:
	_enter_hover()


func _boss_physics(delta: float) -> void:
	time += delta
	state_time -= delta
	# El aura late; más rápido cuanto menos vida le queda.
	var pulse := 1.0 + 0.1 * sin(time * (3.0 + float(phase) * 2.0))
	aura.scale = Vector2.ONE * pulse

	match state:
		State.HOVER:
			_hover()
			if state_time <= 0.0:
				_enter_telegraph()
		State.TELEGRAPH:
			velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
			if state_time <= 0.0:
				_attack()
		State.SWEEP:
			var spd := sweep_speed
			if phase == 2:
				spd = sweep_speed * 1.45  # con TU dash
			elif phase == 3:
				spd = sweep_speed * 0.7   # lento y pesado
			velocity = sweep_dir * spd
			if is_on_wall() or state_time <= 0.0:
				_enter_hover()
		State.VOLLEY_RECOVER:
			velocity = velocity.move_toward(Vector2(0, -160), 700.0 * delta)
			if state_time <= 0.0:
				_enter_hover()


func _hover() -> void:
	if player == null:
		return
	var target: Vector2 = player.global_position + Vector2(0, -150)
	target.y += sin(time * 2.5) * 24.0
	velocity = ((target - global_position) * 1.8).limit_length(300.0)


func _enter_hover() -> void:
	state = State.HOVER
	var interval := attack_interval
	if phase == 2:
		interval *= 0.6
	elif phase == 3:
		interval *= 1.4
	state_time = interval
	body.color = base_color


func _enter_telegraph() -> void:
	state = State.TELEGRAPH
	state_time = telegraph_time if phase != 2 else telegraph_time * 0.55
	body.color = Color(0.85, 0.3, 0.4)
	wants_sweep = dist_to_player() < 300.0 or phase == 2 or randf() < 0.4


func _attack() -> void:
	body.color = base_color
	if wants_sweep and player != null:
		sweep_dir = (player.global_position - global_position).normalized()
		state = State.SWEEP
		state_time = 0.8
		if phase == 2:
			Audio.play("dash", 0.1)  # usa TU dash: que se escuche
	else:
		_fire_volley()
		state = State.VOLLEY_RECOVER
		state_time = 0.6


func _fire_volley() -> void:
	if projectile_scene == null or player == null:
		return
	var count := volley_count if phase != 3 else volley_count + 3
	var base_angle: float = (player.global_position - global_position).angle()
	for i in count:
		var t := 0.0 if count == 1 else float(i) / float(count - 1) - 0.5
		var proj = projectile_scene.instantiate()
		get_parent().add_child(proj)
		proj.global_position = global_position
		if proj.has_method("setup_vector"):
			proj.setup_vector(Vector2.from_angle(base_angle + t * 0.6) * projectile_speed)
	Audio.play("shoot", 0.1)


# Tres fases por tercios de vida (en vez de las dos de la base).
func _check_phase() -> void:
	if phase == 1 and health <= int(max_health * 2.0 / 3.0):
		phase = 2
		_on_phase_changed(2)
	elif phase == 2 and health <= int(max_health / 3.0):
		phase = 3
		_on_phase_changed(3)


func _on_phase_changed(new_phase: int) -> void:
	var dialogue = get_tree().get_first_node_in_group("dialogue")
	if new_phase == 2:
		# EL ROBO: te come el dash y lo usa contra vos.
		if player != null and "has_dash" in player and player.has_dash:
			player.has_dash = false
			stole_dash = true
		base_color = Color(0.25, 0.1, 0.3)
		body.color = base_color
		if dialogue != null:
			dialogue.show_dialogue("El Silencio", ["TE LO SACO."])
	elif new_phase == 3:
		# Devuelve lo robado: ya no le sirve. Y se hace el silencio.
		_return_stolen()
		Audio.stop_music()
		_set_darkness(true)
		base_color = Color(0.05, 0.05, 0.08)
		body.color = base_color
		if dialogue != null:
			dialogue.show_dialogue("El Silencio", ["...", "tengo hambre"])


func _return_stolen() -> void:
	if stole_dash and player != null and player.has_method("refresh_abilities"):
		player.refresh_abilities()
		stole_dash = false


# Oscuridad de fase 3: reusa el overlay de niebla a máxima densidad.
func _set_darkness(on: bool) -> void:
	var manager = get_tree().get_first_node_in_group("rooms")
	if manager == null:
		return
	var overlay = manager.get_node_or_null("FogOverlay")
	if overlay != null:
		overlay.visible = on
		if on:
			overlay.get_node("TextureRect").modulate.a = 1.0


# No se libera al morir: se disuelve y corta al final.
func _should_free_on_death() -> bool:
	return false


func _on_defeated() -> void:
	_return_stolen()
	_set_darkness(false)
	$ContactDamage/CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	visible = false
	# Un respiro… y el final (normal o verdadero según lleves la Semilla).
	var timer := get_tree().create_timer(2.2)
	timer.timeout.connect(func():
		get_tree().change_scene_to_file("res://scenes/ending.tscn")
	)
