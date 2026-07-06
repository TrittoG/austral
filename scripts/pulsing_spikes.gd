extends Area2D

# ============================================================
#  PULSING SPIKES — espinas vivas (Raíz)
#  Crecen y se retraen con ritmo. Solo dañan extendidas.
#  Desfasá varios con "offset" para hacer pasillos con timing.
# ============================================================

## Duración del ciclo completo (s).
@export var period: float = 2.4
## Fracción del ciclo con las espinas afuera (0.5 = mitad y mitad).
@export_range(0.1, 0.9) var active_fraction: float = 0.45
## Desfase inicial (s), para alternar espinas vecinas.
@export var offset: float = 0.0

var _time: float = 0.0

@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Polygon2D = $Polygon2D


func _ready() -> void:
	_time = offset


func _physics_process(delta: float) -> void:
	_time += delta
	var phase := fmod(_time, period) / period
	var active := phase < active_fraction
	shape.set_deferred("disabled", not active)
	# Aviso visual: medio segundo antes de salir, asoman traslúcidas.
	var warning := not active and phase > 1.0 - (0.5 / period)
	if active:
		visual.color.a = 1.0
		visual.position.y = 0.0
	elif warning:
		visual.color.a = 0.4
		visual.position.y = 12.0
	else:
		visual.color.a = 0.12
		visual.position.y = 16.0
