extends Area2D

# ============================================================
#  MERCHANT — el Chatarrero (NPC de tienda)
#  Te parás cerca y apretás "interact" (↑): abre la tienda.
#  El catálogo vive en Game.SHOP_ITEMS; la UI es shop_menu.
# ============================================================

var player_in_range: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		var menu = get_tree().get_first_node_in_group("shop_menu")
		if menu != null:
			menu.open()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
