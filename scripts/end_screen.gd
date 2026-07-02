extends Control

# ============================================================
#  END SCREEN — fin de la demo
#  La abre el portal de p1_exit. Muestra un cierre + tus
#  números de la corrida y vuelve al menú.
# ============================================================

@onready var stats: Label = $Center/VBox/Stats
@onready var back_button: Button = $Center/VBox/BackButton


func _ready() -> void:
	stats.text = "Jefes derrotados: %d / 2      Vida máxima: %d\nAntimateria: ◆ %d      Amuletos: %d / %d" % [
		Game.bosses_defeated.size(),
		Game.max_health,
		Game.currency,
		Game.charms_owned.size(),
		Game.CHARMS.size(),
	]
	back_button.pressed.connect(_back_to_title)
	back_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or event.is_action_pressed("interact"):
		_back_to_title()


func _back_to_title() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
