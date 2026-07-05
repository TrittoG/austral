extends Area2D

# ============================================================
#  ECO — criatura que no terminó de morir
#  Al acercarte dice su única línea (flotando sobre él, con
#  efecto máquina de escribir, SIN pausar el juego) y después
#  se disuelve. Reaparece si volvés a entrar a la sala: los
#  ecos repiten lo último que pensaron, para siempre.
# ============================================================

## La única línea del eco.
@export_multiline var text: String = "..."
## Velocidad del texto (caracteres por segundo).
@export var chars_per_second: float = 26.0
## Segundos que la línea queda visible completa antes de disolverse.
@export var linger_time: float = 2.2

var _spoken: bool = false
var _fading: bool = false
var _reveal: float = 0.0

@onready var label: Label = $Label


func _ready() -> void:
	label.text = ""
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _spoken or not body.is_in_group("player"):
		return
	_spoken = true
	label.text = text
	label.visible_characters = 0


func _process(delta: float) -> void:
	if not _spoken or _fading:
		return
	var total := text.length()
	if label.visible_characters < total:
		_reveal += chars_per_second * delta
		label.visible_characters = mini(int(_reveal), total)
	else:
		_start_fade()


func _start_fade() -> void:
	_fading = true
	var tween := create_tween()
	tween.tween_interval(linger_time)
	tween.tween_property(self, "modulate:a", 0.0, 1.6)
	tween.tween_callback(queue_free)
