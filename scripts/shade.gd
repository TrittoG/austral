extends Area2D

# ============================================================
#  SHADE — tu antimateria perdida
#  Aparece donde moriste con la antimateria que llevabas.
#  Tocarla la recupera toda. Si morís de nuevo con plata encima
#  antes de recuperarla, la pila nueva reemplaza a esta.
#  La instancia el RoomManager al cargar la sala donde moriste.
# ============================================================

var _time: float = 0.0
var _base_y: float = 0.0

@onready var label: Label = $Label


func _ready() -> void:
	_base_y = position.y
	label.text = "◆ %d" % Game.lost_currency
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * 2.0) * 7.0


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	Game.recover_lost_currency()
	Audio.play("coin", 0.1)
	queue_free()
