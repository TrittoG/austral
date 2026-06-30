extends Control

# ============================================================
#  TITLE SCREEN — menú mínimo
#  Continuar (carga el save) / Nueva partida / Salir.
#  Ambos caminos terminan cargando main.tscn; la diferencia
#  es si antes cargamos el save o reseteamos el estado.
# ============================================================

@onready var continue_button: Button = $Center/VBox/ContinueButton
@onready var new_button: Button = $Center/VBox/NewButton
@onready var quit_button: Button = $Center/VBox/QuitButton


func _ready() -> void:
	# "Continuar" solo está disponible si hay una partida guardada.
	continue_button.disabled = not Game.has_save()
	continue_button.pressed.connect(_on_continue)
	new_button.pressed.connect(_on_new_game)
	quit_button.pressed.connect(_on_quit)

	# Foco inicial para poder navegar con teclado.
	if continue_button.disabled:
		new_button.grab_focus()
	else:
		continue_button.grab_focus()


func _on_continue() -> void:
	if Game.load_game():
		get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_new_game() -> void:
	Game.new_game()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit() -> void:
	get_tree().quit()
