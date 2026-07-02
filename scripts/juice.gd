extends Node

# ============================================================
#  JUICE — singleton de game feel (autoload)
#  Helpers globales que dan "jugo" al juego. Por ahora solo
#  hitstop; en la Fase 10 acá van screen shake, etc.
# ============================================================

# Cuántos hitstops hay activos. Si se encadenan golpes, el último
# en terminar es el que restaura el tiempo (evita destrabar de más).
var _hitstop_count: int = 0

# ---- Screen shake ------------------------------------------
var _shake_amount: float = 0.0
var _shake_decay: float = 0.0
var _camera: Camera2D = null


# Sacude la cámara. amount en píxeles (2-4 sutil, 6-10 golpe fuerte).
# OJO: poco. El screen shake de más es mareante.
func shake(amount: float, duration: float = 0.2) -> void:
	_shake_amount = maxf(_shake_amount, amount)
	_shake_decay = maxf(_shake_decay, amount / maxf(duration, 0.01))


func _process(delta: float) -> void:
	if _shake_amount <= 0.0:
		return
	if _camera == null or not is_instance_valid(_camera):
		_find_camera()
		if _camera == null:
			_shake_amount = 0.0
			return
	_shake_amount = maxf(_shake_amount - _shake_decay * delta, 0.0)
	if _shake_amount > 0.0:
		_camera.offset = Vector2(
			randf_range(-_shake_amount, _shake_amount),
			randf_range(-_shake_amount, _shake_amount)
		)
	else:
		_camera.offset = Vector2.ZERO


func _find_camera() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_node("Camera2D"):
		_camera = player.get_node("Camera2D") as Camera2D


# Congela el juego unos milisegundos en el momento del impacto.
# Es lo que hace que pegar "pegue": el golpe se siente contundente.
# duration en segundos (2-4 frames @60fps ≈ 0.03-0.07).
func hitstop(duration: float) -> void:
	_hitstop_count += 1
	Engine.time_scale = 0.0
	# El timer ignora time_scale (último arg = true) para poder
	# contar tiempo real mientras el juego está congelado.
	await get_tree().create_timer(duration, true, false, true).timeout
	_hitstop_count -= 1
	if _hitstop_count <= 0:
		_hitstop_count = 0
		Engine.time_scale = 1.0
