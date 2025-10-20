# GameManager.gd (Godot 4)
extends Node
class_name GameManager

signal game_started
signal wave_started(wave_index: int)
signal wave_cleared(wave_index: int)
signal game_over(final_score: int)

@export_node_path("Node2D") var world_path: NodePath
@export_node_path("Node") var spawner_path: NodePath
@export_node_path("CanvasLayer") var ui_layer_path: NodePath
@export var player_scene: PackedScene
@export var waves_config: Resource  # opcional (p.ej. Waves.tres)
@export var spawn_delay := 1.0
@export var spawn_invulnerability_time := 1.25

# Estado de la partida
var score: int = 0
var lives: int = 3
var wave_index: int = 0
var is_paused: bool = false
var _player: Node = null
var _ui: CanvasLayer = null

@onready var _world: Node2D = get_node(world_path)
@onready var _spawner: Spawner = get_node(spawner_path)
@onready var _hud: HUD = _world.get_node("UI/HUD") as HUD

var _active_asteroids := 0

func _ready() -> void:
	assert(_world != null, "GameManager: falta World.")	
	assert(_spawner != null, "GameManager: falta Spawner.")
	assert(_hud != null, "GameManager: falta HUD.")
	_hud.reset()
	_spawner.asteroid_spawned.connect(_on_asteroid_spawned)	
	# Arranca en título o directamente en partida según tu flujo:
	start_game()

# =========================================================
# ==============   RESPONSABILIDADES CLAVE   ==============
# =========================================================
# 1) Orquestar el ciclo de vida de la partida (start → waves → game over)
# 2) Mantener estado global: score, vidas, wave actual, pausa
# 3) Spawnear y cablear al Player (y su Weapon) con el Spawner
# 4) Escuchar señales de destrucción (asteroide/UFO) para score y progreso de oleada
# 5) Declarar fin de oleada y disparar la siguiente
# 6) Gestionar pausa (integración con tu PauseController si lo usas)
# 7) Notificar a la UI (HUD/Overlays) mediante señales o llamadas directas

# ---------------------------
# Ciclo de partida / waves
# ---------------------------
func start_game() -> void:
	score = 0
	lives = 3
	wave_index = 0
	_clear_world()
	_spawn_player()
	_start_wave(wave_index)
	emit_signal("game_started")
	_update_hud_all()

func _start_wave(index: int) -> void:
	print("START_WAVE ", index)
	_spawner.spawn_wave(index)
	emit_signal("wave_started", index)
	_update_ui_wave()

func _on_wave_cleared() -> void:
	print("_ON_WAVE_CLEARED()")
	emit_signal("wave_cleared", wave_index)
	wave_index += 1
	_start_wave(wave_index)

# ======================================================
# =============== Ciclo de vida del Player =============
# ======================================================
func _spawn_player() -> void:
	_player = player_scene.instantiate()	
	_world.call_deferred("add_child", _player)
	_player.died.connect(_on_player_died)
	
	var weapon := _player.get_node_or_null("Weapon")	
	_spawner.connect_weapon(weapon)

	_update_ui_lives()

func _on_player_died() -> void:
	lives -= 1
	_update_ui_lives()
	
	# Limpiar referencia (se hace queue_free en _die()
	_player = null
	
	if lives > 0:
		_respawn_after_delay()
	else:
		_game_over()

func _respawn_after_delay() -> void:
	# Pequeño retardo para feedback visual/sonoro
	await get_tree().create_timer(spawn_delay).timeout
	_spawn_player()

# ======================================================
# =================== HUD / Marcadores =================
# ======================================================
func _on_asteroid_spawned(a: Asteroid) -> void:
	assert(a is Asteroid, "Spawner emitió algo que no es Asteroid")
	_active_asteroids += 1
	a.destroyed.connect(_on_asteroid_destroyed)

func _on_asteroid_destroyed(position: Vector2, size: int) -> void:
	#print("_on_asteroid_destroyed ->", size)
	score += 50 * (size + 1)
	_update_ui_score()
	_check_wave_cleared()

func on_ufo_destroyed(points: int = 250) -> void:
	score += points
	_update_ui_score()
	_check_wave_cleared()

func _check_wave_cleared() -> void:
	if _spawner.is_wave_cleared():
		_on_wave_cleared()

# ---------------------------
# Pausa
# ---------------------------
func toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused
	# Si usas PauseController.gd en UI, puedes notificarle:
	# _ui.get_node("PauseController").set_visible(is_paused)
	_update_ui_pause()

# ---------------------------
# Game Over
# ---------------------------
func _game_over() -> void:
	# Limpia mundo y muestra overlay GameOver (si existe en tu UI)
	_clear_world()
	emit_signal("game_over", score)
	_show_game_over()

# ---------------------------
# Utilidades
# ---------------------------
func _clear_world() -> void:
	if not _world:
		return
	# Opcional: usar grupos "asteroids", "bullets", "enemies" para limpiar más rápido
	for node in get_tree().get_nodes_in_group("spawn"):
		if is_instance_valid(node):
			node.queue_free()

# ---------------------------
# UI helpers (mínimos)
# ---------------------------
func _update_hud_all() -> void:
	if _hud:
		_hud.reset(score, lives, wave_index + 1)

func _update_ui_score() -> void:
	_hud.set_score(score)

func _update_ui_lives() -> void:
	_hud.set_lives(lives)

func _update_ui_wave() -> void:
	_hud.set_level(wave_index + 1)
	
func _update_ui_pause() -> void:
	if not _ui:
		return
	var pause_overlay := _ui.get_node_or_null("PauseMenu")
	if pause_overlay and pause_overlay.has_method("set_visible"):
		pause_overlay.set_visible(is_paused)

func _show_game_over() -> void:
	if not _ui:
		return
	var go := _ui.get_node_or_null("GameOver")
	if go and go.has_method("show_final_score"):
		go.show_final_score(score)
