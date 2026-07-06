extends Area2D

# ============================================================
#  ROOT SPIKE — raíz que emerge del suelo (ataque de la Jardinera)
#  Telegrafía medio segundo (sombra traslúcida), brota con daño
#  activo un rato, se retrae y desaparece. La spawnea el jefe
#  en la posición del player.
# ============================================================

@export var warn_time: float = 0.55
@export var active_time: float = 0.6

var _time: float = 0.0

@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Polygon2D = $Polygon2D


func _ready() -> void:
	shape.disabled = true
	visual.color.a = 0.35
	visual.scale.y = 0.25


func _physics_process(delta: float) -> void:
	_time += delta
	if _time < warn_time:
		return
	if _time < warn_time + active_time:
		shape.set_deferred("disabled", false)
		visual.color.a = 1.0
		visual.scale.y = 1.0
	else:
		shape.set_deferred("disabled", true)
		visual.color.a = 0.3
		visual.scale.y = maxf(visual.scale.y - 3.0 * delta, 0.05)
		if _time > warn_time + active_time + 0.4:
			queue_free()
