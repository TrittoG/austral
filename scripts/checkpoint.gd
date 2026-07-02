extends Area2D

# ============================================================
#  CHECKPOINT (banco, estilo Hollow Knight)
#  Te parás encima y apretás "interact" (E): guarda la partida,
#  fija este punto como respawn y te recupera la vida.
# ============================================================

## Si recupera la vida al usarlo.
@export var restore_health: bool = true

# Colores del placeholder: dorado si es el banco activo, apagado si no.
const ACTIVE_COLOR := Color(1.0, 0.85, 0.3, 1.0)
const IDLE_COLOR := Color(0.55, 0.5, 0.3, 1.0)

var player_in_range: bool = false

@onready var visual: ColorRect = $ColorRect


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_refresh_visual()


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		_activate()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false


func _activate() -> void:
	# Sala actual según el manager (la posición es la del banco).
	var manager = get_tree().get_first_node_in_group("rooms")
	var room_path := ""
	if manager != null:
		room_path = manager.current_room_path

	Game.set_checkpoint(room_path, global_position)
	Game.save_game()
	Audio.play("checkpoint")

	if restore_health:
		var player = get_tree().get_first_node_in_group("player")
		if player != null and player.has_method("full_heal"):
			player.full_heal()

	_refresh_visual()

	# Descansar en el banco abre el menú de amuletos (estilo Hollow Knight:
	# solo se cambian sentado en un banco).
	var menu = get_tree().get_first_node_in_group("charm_menu")
	if menu != null:
		menu.open()


# Dorado si este banco es el checkpoint guardado.
func _refresh_visual() -> void:
	var cp := Game.get_checkpoint()
	var is_active: bool = cp["room"] != "" and cp["position"].distance_to(global_position) < 1.0
	visual.color = ACTIVE_COLOR if is_active else IDLE_COLOR
