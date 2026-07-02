extends Node

# ============================================================
#  AUDIO MANAGER (autoload "Audio")
#  Reproduce SFX por nombre desde un pool de players en el bus
#  "SFX", con variación de pitch opcional. También un canal de
#  música en el bus "Music" (para cuando tengas temas).
#
#  Los SFX son placeholders sintéticos (assets/audio/sfx). Para
#  cambiarlos, reemplazá el .wav manteniendo el nombre.
# ============================================================

const SFX_DIR := "res://assets/audio/sfx/"
const SFX_NAMES: Array[String] = [
	"jump", "land", "dash", "attack", "hit", "boss_hit",
	"hurt", "shoot", "enemy_death", "checkpoint", "coin",
]
const POOL_SIZE := 12

var _sfx: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next: int = 0
var _music: AudioStreamPlayer
var _music_path: String = ""


func _ready() -> void:
	# Cargar los SFX disponibles (si falta alguno, se ignora).
	for sfx_name in SFX_NAMES:
		var path := SFX_DIR + sfx_name + ".wav"
		if ResourceLoader.exists(path):
			_sfx[sfx_name] = load(path)

	# Pool de players para SFX solapados.
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)

	# Canal de música. Al terminar el stream, vuelve a arrancar (loop).
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	add_child(_music)
	_music.finished.connect(_music.play)


# Reproduce un SFX por nombre. pitch_variation = ±rango aleatorio.
func play(sfx_name: String, pitch_variation: float = 0.0, volume_db: float = 0.0) -> void:
	if not _sfx.has(sfx_name):
		return
	var p := _players[_next]
	_next = (_next + 1) % _players.size()
	p.stream = _sfx[sfx_name]
	p.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	p.volume_db = volume_db
	p.play()


# Reproduce música (un AudioStream), opcionalmente en loop.
func play_music(stream: AudioStream, loop: bool = true) -> void:
	if stream == null:
		return
	_music.stream = stream
	# Si el stream soporta loop, lo activamos.
	if loop and "loop" in stream:
		stream.loop = true
	_music.play()


# Reproduce música por ruta de archivo. Si ya está sonando esa misma
# pista, no la reinicia: así el tema sigue de largo entre salas del
# mismo planeta. La usa el RoomManager con room.music_track.
func play_music_path(path: String) -> void:
	if path == _music_path:
		return
	_music_path = path
	if path == "" or not ResourceLoader.exists(path):
		_music.stop()
		return
	_music.stream = load(path)
	_music.play()


func stop_music() -> void:
	_music_path = ""
	_music.stop()
