extends Area2D

# ============================================================
#  UPDRAFT — géiser / corriente ascendente (El Velo)
#  Mientras el player está adentro, lo empuja hacia arriba.
#  Saltá adentro y dejate llevar; salir corta el empuje.
# ============================================================

## Fuerza de empuje (px/s²). La gravedad de caída es ~1800: con 2600
## el ascenso es firme pero flotante.
@export var strength: float = 2600.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if "updraft_force" in body:
		body.updraft_force = strength


func _on_body_exited(body: Node2D) -> void:
	if "updraft_force" in body:
		body.updraft_force = 0.0
