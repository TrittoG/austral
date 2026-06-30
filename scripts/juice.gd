extends Node

# ============================================================
#  JUICE — singleton de game feel (autoload)
#  Helpers globales que dan "jugo" al juego. Por ahora solo
#  hitstop; en la Fase 10 acá van screen shake, etc.
# ============================================================

# Cuántos hitstops hay activos. Si se encadenan golpes, el último
# en terminar es el que restaura el tiempo (evita destrabar de más).
var _hitstop_count: int = 0


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
