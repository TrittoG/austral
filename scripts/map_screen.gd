extends CanvasLayer

# ============================================================
#  MAP SCREEN — pantalla de mapa (tecla M)
#  Dos vistas, estilo Hollow Knight:
#  - Planeta: salas descubiertas del mundo actual + tu posición.
#  - Galaxia: los mundos que existen (los no visitados: "???").
#  TAB cambia de vista. M o Esc cierra. Pausa mientras está abierto.
# ============================================================

@onready var view: Control = $Frame/MapView
@onready var title: Label = $Frame/Title


func _ready() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("map"):
		if visible:
			close()
		else:
			# No abrir encima de otro menú (pausa, amuletos).
			if get_tree().paused:
				return
			open()
		get_viewport().set_input_as_handled()
	elif visible and (event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel")):
		close()
		get_viewport().set_input_as_handled()
	elif visible and (event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right")):
		_switch_view()
		get_viewport().set_input_as_handled()


func open() -> void:
	visible = true
	get_tree().paused = true
	view.mode = "planet"
	_update_title()
	view.queue_redraw()


func close() -> void:
	visible = false
	get_tree().paused = false


func _switch_view() -> void:
	view.mode = "galaxy" if view.mode == "planet" else "planet"
	_update_title()
	view.queue_redraw()


func _update_title() -> void:
	if view.mode == "galaxy":
		title.text = "GALAXIA"
		return
	var manager = get_tree().get_first_node_in_group("rooms")
	var planet := ""
	if manager != null:
		planet = Atlas.planet_of_room(manager.current_room_path)
	var planet_name: String = Atlas.PLANETS.get(planet, {}).get("name", "Zona desconocida")
	title.text = "MAPA — %s" % planet_name
