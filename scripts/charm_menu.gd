extends CanvasLayer

# ============================================================
#  CHARM MENU — equipar amuletos (solo en bancos)
#  Lo abre el checkpoint al descansar. Pausa el juego mientras
#  está abierto. Lista los amuletos que tenés; clic para
#  equipar/desequipar, limitado por muescas. Al cerrar, guarda.
# ============================================================

@onready var notches_label: Label = $Frame/VBox/Notches
@onready var list: VBoxContainer = $Frame/VBox/List
@onready var empty_label: Label = $Frame/VBox/Empty
@onready var close_button: Button = $Frame/VBox/CloseButton


func _ready() -> void:
	add_to_group("charm_menu")
	visible = false
	close_button.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("interact"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	visible = true
	get_tree().paused = true
	_rebuild()


func close() -> void:
	visible = false
	# Diferido al fin del frame: si cerrás con E, el banco (que también
	# escucha E) no debe ver la tecla este mismo frame y reabrir el menú.
	get_tree().set_deferred("paused", false)
	# Los cambios de amuletos hechos en el banco quedan guardados.
	Game.save_game()


# Rearma la lista de amuletos según lo que tenés y lo equipado.
func _rebuild() -> void:
	for child in list.get_children():
		child.queue_free()

	notches_label.text = "Muescas: %d / %d" % [Game.used_notches(), Game.charm_notches]
	empty_label.visible = Game.charms_owned.is_empty()

	for id in Game.CHARMS:
		if not Game.is_charm_owned(id):
			continue
		var data: Dictionary = Game.CHARMS[id]
		var equipped := Game.is_charm_equipped(id)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)

		var button := Button.new()
		button.custom_minimum_size = Vector2(250, 40)
		var mark := "[ x ]" if equipped else "[    ]"
		button.text = "%s  %s  (%d)" % [mark, data["name"], data["cost"]]
		button.pressed.connect(_on_toggle.bind(id))
		row.add_child(button)

		var desc := Label.new()
		desc.text = data["desc"]
		desc.add_theme_font_size_override("font_size", 14)
		desc.add_theme_color_override("font_color", Color(0.75, 0.75, 0.7))
		desc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(desc)

		list.add_child(row)


func _on_toggle(id: String) -> void:
	if Game.is_charm_equipped(id):
		Game.unequip_charm(id)
	else:
		# Si no hay muescas suficientes, equip_charm devuelve false
		# y la lista simplemente no cambia.
		Game.equip_charm(id)
	_rebuild()
