extends CanvasLayer

# ============================================================
#  TRAVEL MENU — la nave elige destino
#  Progresión: el Velo se abre al reconstruir la nave; Raíz
#  necesita el Blindaje Estelar (asteroides); la Garganta el
#  Núcleo de Pulso. Los destinos bloqueados muestran qué falta.
#  Volver a planetas ya abiertos = viaje rápido gratis.
# ============================================================

const DESTINATIONS := [
	{
		"planet": "planet1",
		"label": "Páramo del Impacto",
		"room": "res://scenes/rooms/planet1/p1_exit.tscn",
		"door": "FromVelo",
		"needs": "",
	},
	{
		"planet": "planet2",
		"label": "El Velo",
		"room": "res://scenes/rooms/planet2/p2_arrival.tscn",
		"door": "ArrivalPoint",
		"needs": "",
	},
	{
		"planet": "planet3",
		"label": "Raíz",
		"room": "res://scenes/rooms/planet3/p3_arrival.tscn",
		"door": "ArrivalPoint",
		"needs": "blindaje_estelar",
	},
	{
		"planet": "garganta",
		"label": "La Garganta",
		"room": "res://scenes/rooms/garganta/g_arrival.tscn",
		"door": "ArrivalPoint",
		"needs": "nucleo_pulso",
	},
]

@onready var list: VBoxContainer = $Frame/VBox/List
@onready var close_button: Button = $Frame/VBox/CloseButton


func _ready() -> void:
	add_to_group("travel_menu")
	visible = false
	close_button.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	visible = true
	get_tree().paused = true
	_rebuild()


func close() -> void:
	visible = false
	get_tree().set_deferred("paused", false)


func _rebuild() -> void:
	for child in list.get_children():
		child.queue_free()

	var manager = get_tree().get_first_node_in_group("rooms")
	var current_planet := ""
	if manager != null:
		current_planet = Atlas.planet_of_room(manager.current_room_path)

	var buttons: Array = []
	for dest in DESTINATIONS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)

		var here: bool = dest["planet"] == current_planet
		var needs: String = dest["needs"]
		var locked: bool = needs != "" and not Game.has_key_item(needs)

		var button := Button.new()
		button.custom_minimum_size = Vector2(260, 42)
		button.text = dest["label"]
		if here:
			button.text += "  (estás acá)"
			button.disabled = true
		elif locked:
			button.disabled = true
		else:
			button.pressed.connect(_travel.bind(dest["room"], dest["door"]))
		row.add_child(button)
		buttons.append(button)

		if locked:
			var info := Label.new()
			var item_name: String = Game.KEY_ITEMS.get(needs, {}).get("name", needs)
			info.text = "Necesitás: %s" % item_name
			info.add_theme_font_size_override("font_size", 14)
			info.add_theme_color_override("font_color", Color(0.75, 0.55, 0.55))
			info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row.add_child(info)

		list.add_child(row)

	# Foco en el primer destino habilitado.
	for b in buttons:
		if not b.disabled:
			b.grab_focus()
			return
	close_button.grab_focus()


func _travel(room: String, door: String) -> void:
	close()
	Audio.play("dash", 0.0, -4.0)  # despegue placeholder
	var manager = get_tree().get_first_node_in_group("rooms")
	if manager != null:
		manager.go_to_room(room, door)
