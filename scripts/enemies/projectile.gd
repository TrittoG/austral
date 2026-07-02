extends Area2D

# ============================================================
#  PROJECTILE — proyectil enemigo
#  Vuela horizontal en la dirección que le pasa el shooter.
#  Daña al player por estar en el grupo "enemy_hitbox" (su
#  hurtbox lo detecta). Se destruye al tocar pared o player,
#  o al agotar su tiempo de vida.
# ============================================================

@export var speed: float = 230.0
@export var lifetime: float = 4.0

var dir: int = 1
var time_left: float = 0.0
var vel: Vector2 = Vector2.ZERO   # modo vector (jefes): manda sobre dir


func _ready() -> void:
	time_left = lifetime
	# Detecta colisión con mundo (1) y player (2) para autodestruirse.
	body_entered.connect(_on_body_entered)


# La llama el shooter al crearlo (vuelo horizontal simple).
func setup(direction: int) -> void:
	dir = direction


# Modo vector: vuela con esta velocidad exacta (jefes que apuntan).
func setup_vector(velocity: Vector2) -> void:
	vel = velocity


func _physics_process(delta: float) -> void:
	if vel != Vector2.ZERO:
		position += vel * delta
	else:
		position.x += dir * speed * delta
	time_left -= delta
	if time_left <= 0.0:
		queue_free()


func _on_body_entered(_body: Node2D) -> void:
	# Tocó algo sólido (pared) o al player: desaparece.
	queue_free()
