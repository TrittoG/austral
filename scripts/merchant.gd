extends Area2D

# ============================================================
#  MERCHANT / NPC HABLANTE — el Chatarrero (y reutilizable)
#  Te parás cerca y apretás "interact" (↑): habla (caja de
#  diálogo) y, al terminar, abre la tienda si opens_shop.
#  Con opens_shop = false sirve como NPC de diálogo puro
#  (Ermitaña, etc.) cambiando las líneas en el inspector.
# ============================================================

## Nombre que muestra la caja de diálogo.
@export var npc_name: String = "El Chatarrero"
## Líneas del primer encuentro (una vez; persiste en el save).
@export var first_lines: Array[String] = [
	"Un caído vivo. Eso es nuevo.",
	"Yo no robo, Caído. Los muertos no son dueños de nada.",
	"Los vivos, en cambio, pagan. ¿Ves algo que te guste?",
]
## Líneas de las visitas siguientes.
@export var repeat_lines: Array[String] = [
	"¿Antimateria fresca? Pasá, pasá.",
]
## Id único para recordar que ya lo conociste ("" = siempre first_lines).
@export var met_id: String = "npc_chatarrero_met"
## Si abre la tienda al terminar de hablar.
@export var opens_shop: bool = true

var player_in_range: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		_talk()


func _talk() -> void:
	var dialogue = get_tree().get_first_node_in_group("dialogue")
	if dialogue == null:
		_after_dialogue()  # sin sistema de diálogo, ir directo
		return

	var lines: Array = first_lines
	if met_id != "" and Game.is_secret_found(met_id):
		lines = repeat_lines
	elif met_id != "":
		Game.mark_secret_found(met_id)

	dialogue.finished.connect(_after_dialogue, CONNECT_ONE_SHOT)
	dialogue.show_dialogue(npc_name, lines)


func _after_dialogue() -> void:
	if not opens_shop:
		return
	var menu = get_tree().get_first_node_in_group("shop_menu")
	if menu != null:
		menu.open()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
