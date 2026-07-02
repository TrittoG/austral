extends CharacterBody2D

# ============================================================
#  ANTIMATTER — esquirla de antimateria (la moneda)
#  Sale despedida al morir un enemigo o romper una roca, rebota
#  en el piso y se atrae hacia el player cuando está cerca.
#  Al tocarte: suma a Game.currency.
# ============================================================

@export var value: int = 1
@export var gravity: float = 900.0
## Distancia a la que empieza a volar hacia vos.
@export var magnet_range: float = 80.0
@export var magnet_speed: float = 280.0
## Segundos antes de desaparecer si no la agarrás.
@export var lifetime: float = 25.0

var _prev_vy: float = 0.0


func _ready() -> void:
	# Impulso inicial aleatorio, como monedas que saltan del enemigo.
	velocity = Vector2(randf_range(-130.0, 130.0), randf_range(-280.0, -150.0))
	$Collector.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.x = move_toward(velocity.x, 0.0, 350.0 * delta)

	_prev_vy = velocity.y
	move_and_slide()

	# Rebote: si tocó el piso cayendo con velocidad, rebota amortiguado.
	if is_on_floor() and _prev_vy > 140.0:
		velocity.y = -_prev_vy * 0.45

	# Imán suave hacia el player cercano. El amuleto Imán Estelar
	# triplica el alcance.
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		var reach := magnet_range
		if Game.is_charm_equipped("iman_estelar"):
			reach *= 3.0
		var dist := global_position.distance_to(player.global_position)
		if dist < reach:
			global_position = global_position.move_toward(
					player.global_position, magnet_speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	Game.add_currency(value)
	Audio.play("coin", 0.15)
	queue_free()
