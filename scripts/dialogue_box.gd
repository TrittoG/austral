extends CanvasLayer

# ============================================================
#  DIALOGUE BOX — diálogos estilo Hollow Knight
#  Caja abajo, nombre del que habla, texto con efecto máquina
#  de escribir. Z/A avanza (primero revela todo, después pasa
#  de línea). Esc/B saltea el diálogo entero. Pausa el juego.
#
#  Uso: get_tree().get_first_node_in_group("dialogue")
#       .show_dialogue("Nombre", ["línea 1", "línea 2"])
#  La señal finished avisa al terminar (ej: el Chatarrero abre
#  la tienda recién ahí).
# ============================================================

signal finished

## Velocidad del efecto máquina de escribir (caracteres por segundo).
@export var chars_per_second: float = 45.0

var lines: Array = []
var index: int = 0
var _reveal: float = 0.0

@onready var speaker_label: Label = $Panel/Speaker
@onready var text_label: Label = $Panel/Text
@onready var hint_label: Label = $Panel/Hint


func _ready() -> void:
	add_to_group("dialogue")
	visible = false


func show_dialogue(speaker: String, new_lines: Array) -> void:
	if new_lines.is_empty():
		finished.emit()
		return
	lines = new_lines
	speaker_label.text = speaker
	speaker_label.visible = speaker != ""
	visible = true
	get_tree().paused = true
	_set_line(0)


func _process(delta: float) -> void:
	if not visible:
		return
	# Revelado progresivo del texto.
	var total := text_label.text.length()
	if text_label.visible_characters < total:
		_reveal += chars_per_second * delta
		text_label.visible_characters = mini(int(_reveal), total)
	hint_label.visible = text_label.visible_characters >= total


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	var advance := false
	for action in ["ui_accept", "jump", "attack", "interact"]:
		if event.is_action_pressed(action):
			advance = true
			break

	if advance:
		if text_label.visible_characters < text_label.text.length():
			# Primer toque: mostrar la línea completa de una.
			text_label.visible_characters = text_label.text.length()
			_reveal = float(text_label.text.length())
		elif index + 1 >= lines.size():
			_finish()
		else:
			_set_line(index + 1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_finish()  # saltear todo el diálogo
		get_viewport().set_input_as_handled()


func _set_line(i: int) -> void:
	index = i
	text_label.text = lines[i]
	text_label.visible_characters = 0
	_reveal = 0.0


func _finish() -> void:
	visible = false
	finished.emit()
	# Si un handler encadenó otro menú (ej: la tienda tras hablar con el
	# Chatarrero), el juego sigue pausado; si no, se reanuda.
	var keep_paused := false
	for group in ["shop_menu", "charm_menu"]:
		var menu = get_tree().get_first_node_in_group(group)
		if menu != null and menu.visible:
			keep_paused = true
	if not keep_paused:
		# Diferido: que el ↑ del cierre no re-dispare al NPC este frame.
		get_tree().set_deferred("paused", false)
