extends Node2D

# ============================================================
#  ROOM — datos de una sala
#  Por ahora solo los límites de cámara. El RoomManager los
#  lee al cargar la sala y se los pasa a la cámara del player.
#  En fases siguientes acá pueden ir spawns de enemigos, etc.
# ============================================================

@export_group("Límites de cámara")
@export var camera_limit_left: int = 0
@export var camera_limit_top: int = 0
@export var camera_limit_right: int = 1100
@export var camera_limit_bottom: int = 640

@export_group("Ambiente")
## Música de la sala. Si dos salas comparten pista, el tema sigue de
## largo al pasar de una a otra ("" = silencio).
@export_file("*.wav", "*.ogg") var music_track: String = ""
## Niebla densa: casi no se ve nada salvo alrededor tuyo. Se disipa
## si tenés el objeto clave "disipador_ionico" (mundos gaseosos).
@export var fog: bool = false
