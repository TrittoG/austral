extends "res://scripts/room.gd"

# ============================================================
#  BOSS ARENA — sala de jefe
#  Al cruzar el trigger empieza la pelea: se cierra la reja de
#  entrada, aparece la barra de vida y se activa el jefe. Al
#  vencerlo, se abre la reja y desaparece la barra. Si el jefe
#  ya estaba vencido (save), la sala queda libre y sin jefe.
# ============================================================

@onready var gate_shape: CollisionShape2D = $Gate/CollisionShape2D
@onready var gate_visual: ColorRect = $Gate/ColorRect
@onready var fight_trigger: Area2D = $FightTrigger
@onready var boss = $Boss
@onready var boss_ui: CanvasLayer = $BossUI
@onready var health_bar: ProgressBar = $BossUI/HealthBar


func _ready() -> void:
	_set_gate(false)         # reja abierta al inicio
	boss_ui.visible = false

	# Si ya lo venciste, no hay pelea: sacamos al jefe y listo.
	if boss == null or Game.is_boss_defeated(boss.boss_id):
		if boss != null:
			boss.queue_free()
		return

	fight_trigger.body_entered.connect(_on_fight_trigger)
	boss.health_changed.connect(_on_boss_health_changed)
	boss.defeated.connect(_on_boss_defeated)
	health_bar.max_value = boss.max_health
	health_bar.value = boss.max_health


func _on_fight_trigger(body: Node2D) -> void:
	if body.is_in_group("player"):
		_start_fight()


func _start_fight() -> void:
	if not is_instance_valid(boss):
		return
	_set_gate(true)          # traba la entrada
	boss_ui.visible = true
	boss.activate()
	fight_trigger.set_deferred("monitoring", false)


func _on_boss_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func _on_boss_defeated() -> void:
	_set_gate(false)         # abre la salida
	boss_ui.visible = false


func _set_gate(closed: bool) -> void:
	gate_shape.set_deferred("disabled", not closed)
	gate_visual.visible = closed
