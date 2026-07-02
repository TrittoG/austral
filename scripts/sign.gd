extends Node2D

# ============================================================
#  SIGN — cartel de tutorial / ambientación
#  Texto flotante en el mundo, no interactivo. Arrastrá la
#  escena a una sala y escribí el texto en el inspector.
# ============================================================

@export_multiline var text: String = ""

@onready var label: Label = $Label


func _ready() -> void:
	label.text = text
