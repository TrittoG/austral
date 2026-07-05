extends CanvasLayer

# ============================================================
#  PAUSE MENU — pausa + opciones (in-game)
#  Se abre/cierra con Esc. Pausa el árbol (get_tree().paused).
#  Para que el menú siga respondiendo con el juego pausado, el
#  nodo está en process_mode = Always (seteado en la escena).
#  Opciones: volumen por bus (Master/Música/Efectos) y pantalla
#  completa.
# ============================================================

@onready var main_panel: Control = $MainButtons
@onready var options_panel: Control = $Options
@onready var master_slider: HSlider = $Options/VBox/MasterRow/Slider
@onready var music_slider: HSlider = $Options/VBox/MusicRow/Slider
@onready var sfx_slider: HSlider = $Options/VBox/SfxRow/Slider
@onready var fullscreen_check: CheckButton = $Options/VBox/FullscreenCheck


func _ready() -> void:
	visible = false
	$MainButtons/VBox/ResumeButton.pressed.connect(_resume)
	$MainButtons/VBox/OptionsButton.pressed.connect(_show_options)
	$MainButtons/VBox/QuitButton.pressed.connect(_quit_to_title)
	$Options/VBox/BackButton.pressed.connect(_show_main)

	_setup_bus_slider(master_slider, "Master")
	_setup_bus_slider(music_slider, "Music")
	_setup_bus_slider(sfx_slider, "SFX")

	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	fullscreen_check.button_pressed = (
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			_resume()
		else:
			_open()
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed("ui_cancel"):
		# B en joystick: en opciones vuelve al menú, en el menú reanuda.
		if options_panel.visible:
			_show_main()
		else:
			_resume()
		get_viewport().set_input_as_handled()


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
	# Foco inicial: sin esto, flechas/joystick no navegan.
	$MainButtons/VBox/ResumeButton.grab_focus()


func _show_options() -> void:
	main_panel.visible = false
	options_panel.visible = true
	master_slider.grab_focus()  # ←/→ ajustan el slider enfocado


func _quit_to_title() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")


# Conecta un slider (0..1 lineal) a un bus de audio por nombre.
func _setup_bus_slider(slider: HSlider, bus_name: String) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(idx))
	slider.value_changed.connect(_on_bus_volume.bind(idx))


func _on_bus_volume(value: float, bus_idx: int) -> void:
	# Evitamos linear_to_db(0) = -inf clampeando un mínimo.
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(maxf(value, 0.0001)))


func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
