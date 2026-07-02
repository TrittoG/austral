extends Control

# ============================================================
#  INTRO — el contexto mínimo, antes de empezar
#  Tres pantallas de texto. Saltar/atacar avanza; la última
#  arranca el juego. La abre "Nueva partida" (title_screen).
# ============================================================

const LINES: Array[String] = [
	"Algo cruzó la galaxia,\ndejando silencio a su paso.",
	"Tu nave fue una víctima más.\nCaíste en un mundo desconocido,\nlejos de casa.",
	"Encontrá la fuente del tormento.\nEliminala.\nY volvé.",
]

var index: int = 0

@onready var label: Label = $Center/Text
@onready var hint: Label = $Hint


func _ready() -> void:
	label.text = LINES[0]
	hint.text = "Z — continuar"


func _unhandled_input(event: InputEvent) -> void:
	var advance := false
	for action in ["jump", "attack", "interact", "ui_accept"]:
		if event.is_action_pressed(action):
			advance = true
			break
	if not advance:
		return
	index += 1
	if index >= LINES.size():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		label.text = LINES[index]
