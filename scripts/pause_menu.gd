extends CanvasLayer

# ============================================================
#  PAUSE MENU — pausa + opciones (in-game)
#  Se abre/cierra con Esc. Pausa el árbol (get_tree().paused).
#  Para que el menú siga respondiendo con el juego pausado, el
#  nodo está en process_mode = Always (seteado en la escena).
#  Opciones: volumen master y pantalla completa.
# ============================================================

@onready var main_panel: Control = $MainButtons
@onready var options_panel: Control = $Options
@onready var volume_slider: HSlider = $Options/VBox/VolumeRow/VolumeSlider
@onready var fullscreen_check: CheckButton = $Options/VBox/FullscreenCheck


func _ready() -> void:
	visible = false
	$MainButtons/VBox/ResumeButton.pressed.connect(_resume)
	$MainButtons/VBox/OptionsButton.pressed.connect(_show_options)
	$MainButtons/VBox/QuitButton.pressed.connect(_quit_to_title)
	$Options/VBox/BackButton.pressed.connect(_show_main)
	volume_slider.value_changed.connect(_on_volume_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)

	# Reflejar el estado actual en los controles.
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	fullscreen_check.button_pressed = (
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			_resume()
		else:
			_open()


func _open() -> void:
	get_tree().paused = true
	visible = true
	_show_main()


func _resume() -> void:
	get_tree().paused = false
	visible = false


func _show_main() -> void:
	main_panel.visible = true
	options_panel.visible = false


func _show_options() -> void:
	main_panel.visible = false
	options_panel.visible = true


func _quit_to_title() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


func _on_volume_changed(value: float) -> void:
	# Evitamos linear_to_db(0) = -inf clampeando un mínimo audible/mudo.
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(value, 0.0001)))


func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
