extends CharacterBody2D

# ============================================================
#  ENEMY DUMMY — saco de boxeo para probar el combate
#  Sin IA todavía (eso es Fase 2). Solo: recibe golpes, hace
#  feedback (flash + knockback), te daña al tocarte, y muere.
# ============================================================

@export_group("Vida")
## Vida del dummy. Subila para probar varios golpes.
@export var max_health: int = 5

@export_group("Feedback al recibir golpes")
## Empuje al ser golpeado.
@export var knockback_force: float = 220.0
## Color del flash al recibir un golpe.
@export var flash_color: Color = Color(1, 1, 1)
## Duración del flash en segundos.
@export var flash_duration: float = 0.08

@export_group("Física")
## Gravedad propia (cae si lo empujás al vacío).
@export var gravity: float = 980.0
## Cuán rápido frena tras el knockback.
@export var friction: float = 600.0

var health: int
var flash_timer: float = 0.0
var base_color: Color

@onready var body: ColorRect = $Body


func _ready() -> void:
	health = max_health
	base_color = body.color


func _physics_process(delta: float) -> void:
	# Gravedad + frenado del knockback. Lo justo para que reaccione físico.
	if not is_on_floor():
		velocity.y += gravity * delta
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)
	move_and_slide()

	# Apagar el flash cuando se acaba.
	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0:
			body.color = base_color


# La llama el player desde su hitbox de ataque.
func take_damage(amount: int, from_position: Vector2) -> void:
	health -= amount

	# Flash: lo más barato y efectivo para que se vea el impacto.
	body.color = flash_color
	flash_timer = flash_duration

	# Knockback en sentido contrario al atacante.
	var dir := signf(global_position.x - from_position.x)
	if dir == 0.0:
		dir = 1.0
	velocity.x = dir * knockback_force
	velocity.y = -knockback_force * 0.4

	if health <= 0:
		_die()


func _die() -> void:
	# Por ahora simplemente desaparece. El feedback de muerte real va en Fase 2.
	queue_free()
