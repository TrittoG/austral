extends "res://scripts/enemies/enemy_walker.gd"

# ============================================================
#  BEETLE — escarabajo blindado (Raíz)
#  Patrulla como el walker, pero su frente es coraza: los golpes
#  de frente no lo dañan (chispa apagada). Vulnerable por atrás
#  y desde arriba (pogo). Enseña a flanquear.
# ============================================================


func take_damage(amount: int, from_position: Vector2) -> void:
	# Golpe desde arriba (pogo): siempre entra.
	var from_above := from_position.y < global_position.y - 24.0
	# Golpe de frente: el atacante está del lado hacia el que camina.
	var attacker_side := signf(from_position.x - global_position.x)
	var frontal := attacker_side == signf(dir) and not from_above

	if frontal:
		# Coraza: sin daño, apenas un aviso visual y sonoro.
		body.color = Color(0.6, 0.6, 0.65)
		flash_timer = 0.06
		Audio.play("attack", 0.1, -8.0)
		return

	super.take_damage(amount, from_position)
