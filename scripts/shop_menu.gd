extends CanvasLayer

# ============================================================
#  SHOP MENU — la tienda del Chatarrero
#  Compras únicas con antimateria. Lo comprado se marca en
#  secrets_found (persiste). Pausa mientras está abierta.
# ============================================================

@onready var currency_label: Label = $Frame/VBox/Currency
@onready var list: VBoxContainer = $Frame/VBox/List
@onready var close_button: Button = $Frame/VBox/CloseButton


func _ready() -> void:
	add_to_group("shop_menu")
	visible = false
	close_button.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	# OJO: interact (↑) NO cierra: ↑/↓ navegan la lista.
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


# Qué artículos muestra esta apertura (vacío = catálogo completo).
var _filter: PackedStringArray = []


# filter_items: ids de SHOP_ITEMS que vende este NPC en particular.
func open(filter_items: PackedStringArray = PackedStringArray()) -> void:
	_filter = filter_items
	visible = true
	get_tree().paused = true
	_rebuild()


func close() -> void:
	visible = false
	# Diferido: que el Chatarrero no vea el ↑ de cierre y reabra.
	get_tree().set_deferred("paused", false)


func _rebuild(focus_index: int = 0) -> void:
	for child in list.get_children():
		child.queue_free()

	currency_label.text = "Tenés  ◆ %d" % Game.currency

	var buttons: Array = []
	var row_index := 0
	for id in Game.SHOP_ITEMS:
		if not _filter.is_empty() and id not in _filter:
			continue
		var data: Dictionary = Game.SHOP_ITEMS[id]
		var price: int = data["price"]
		var sold: bool = Game.is_secret_found(id)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)

		var buy := Button.new()
		buy.custom_minimum_size = Vector2(150, 40)
		if sold:
			buy.text = "VENDIDO"
			buy.disabled = true
		else:
			buy.text = "◆ %d" % price
			buy.disabled = Game.currency < price
			buy.pressed.connect(_on_buy.bind(id, row_index))
		row.add_child(buy)
		buttons.append(buy)

		var info := Label.new()
		info.text = "%s — %s" % [data["name"], data["desc"]]
		info.add_theme_font_size_override("font_size", 15)
		info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(info)

		list.add_child(row)
		row_index += 1

	# Foco para navegar sin mouse; tras comprar, se queda en la misma fila.
	if buttons.is_empty():
		close_button.grab_focus()
	else:
		buttons[clampi(focus_index, 0, buttons.size() - 1)].grab_focus()


func _on_buy(id: String, row_index: int = 0) -> void:
	var data: Dictionary = Game.SHOP_ITEMS[id]
	var price: int = data["price"]
	if Game.currency < price or Game.is_secret_found(id):
		return

	Game.add_currency(-price)
	Game.mark_secret_found(id)

	# El efecto de cada compra se resuelve acá.
	match id:
		"shop_heart":
			Game.max_health += 1
			var player = get_tree().get_first_node_in_group("player")
			if player != null and player.has_method("apply_charms"):
				player.apply_charms()
				player.full_heal()
		"shop_notch":
			Game.charm_notches += 1
		"shop_charm_iman":
			Game.own_charm("iman_estelar")
		"shop_charm_oido":
			Game.own_charm("oido_fino")

	Audio.play("checkpoint")
	Game.save_game()  # la compra queda guardada ya mismo
	_rebuild(row_index)
