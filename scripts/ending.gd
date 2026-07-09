extends Control

# ============================================================
#  ENDING — el final del juego
#  Dos versiones según lleves LA MADERA (la Semilla):
#   - NORMAL: lo apagaste y volvés a casa.
#   - VERDADERO: plantás la Semilla en el cráter del Silencio y
#     la galaxia se enciende de a poco (los círculos = planetas).
#  Después: créditos mínimos y vuelta al menú.
# ============================================================

@onready var title_label: Label = $Center/VBox/Title
@onready var text_label: Label = $Center/VBox/Text
@onready var stats_label: Label = $Center/VBox/Stats
@onready var credits_label: Label = $Center/VBox/Credits
@onready var galaxy: Control = $Center/VBox/Galaxy
@onready var back_button: Button = $Center/VBox/BackButton

var _lit: float = 0.0
var _true_ending: bool = false


func _ready() -> void:
	_true_ending = Game.has_key_item("madera")
	Audio.stop_music()

	if _true_ending:
		title_label.text = "ALGO EMPEZÓ A CANTAR"
		text_label.text = "Plantaste la Semilla donde más dolía.\nBebió mil mundos robados… y brotó."
	else:
		title_label.text = "EL SILENCIO SE APAGÓ"
		text_label.text = "La galaxia no volvió a cantar.\nPero tampoco volvió a callarse.\nEs hora de volver a casa."

	stats_label.text = "Jefes: %d      Vida máxima: %d      Amuletos: %d / %d      ◆ %d" % [
		Game.bosses_defeated.size(),
		Game.max_health,
		Game.charms_owned.size(),
		Game.CHARMS.size(),
		Game.currency,
	]
	credits_label.text = "AUSTRAL\nun juego de Giuli\nsistemas: Claude\n\ngracias por jugar"
	back_button.pressed.connect(_back)
	back_button.grab_focus()
	galaxy.draw.connect(_draw_galaxy)


func _process(delta: float) -> void:
	# En el final verdadero, los planetas se encienden de a poco.
	if _true_ending and _lit < 1.0:
		_lit = minf(_lit + delta * 0.15, 1.0)
		galaxy.queue_redraw()


func _draw_galaxy() -> void:
	var size: Vector2 = galaxy.size
	var i := 0
	var total := Atlas.PLANETS.size()
	for id in Atlas.PLANETS:
		var data: Dictionary = Atlas.PLANETS[id]
		var center := Vector2(data["pos"].x * size.x, data["pos"].y * size.y)
		var threshold := float(i + 1) / float(total)
		var on := _true_ending and _lit >= threshold
		var color: Color = data["color"] if on else Color(0.18, 0.18, 0.22)
		galaxy.draw_circle(center, 16.0, color)
		if on:
			galaxy.draw_arc(center, 22.0, 0.0, TAU, 32, Color(1, 1, 0.9, 0.5), 1.5)
		i += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		_back()


func _back() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
