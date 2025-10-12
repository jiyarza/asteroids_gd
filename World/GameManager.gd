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

# Estado de la partida
var score: int = 0
var lives: int = 3
var wave_index: int = 0
var is_paused: bool = false
var _player: Node = null
var _world: Node2D = null
var _spawner: Node = null
var _ui: CanvasLayer = null

func _ready() -> void:
	_world = get_node_or_null(world_path)
	_spawner = get_node_or_null(spawner_path)
	_ui = get_node_or_null(ui_layer_path)

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
	_update_ui_all()

func _start_wave(index: int) -> void:
	# Genera la oleada actual (asteroides grandes, etc.)
	# Si tienes un Waves.tres con configuración, léela aquí
	if _spawner and _spawner.has_method("spawn_wave"):
		_spawner.spawn_wave(index)
	emit_signal("wave_started", index)
	_update_ui_wave()

func _on_wave_cleared() -> void:
	emit_signal("wave_cleared", wave_index)
	wave_index += 1
	_start_wave(wave_index)

# ---------------------------
# Player: spawn y cableado
# ---------------------------
func _spawn_player() -> void:
	if not player_scene:
		push_warning("GameManager: player_scene no asignado.")
		return
	if not _world:
		push_warning("GameManager: world_path no asignado.")
		return

	_player = player_scene.instantiate()
	
	_world.call_deferred("add_child", _player)

	# Conexiones/contratos esperados del Player
	# - Señal "died" (cuando pierde una vida)
	# - Referencia/nodo hijo "Weapon" que emite fire_requested
	if _player.has_signal("died"):
		_player.died.connect(_on_player_died)

	# Cablear Weapon -> Spawner (para instanciar balas)
	var weapon := _player.get_node_or_null("Weapon")
	if weapon and _spawner and _spawner.has_method("connect_weapon"):
		_spawner.connect_weapon(weapon)

	_update_ui_lives()

func _on_player_died() -> void:
	lives -= 1
	_update_ui_lives()
	if lives > 0:
		# Respawn rápido del jugador
		_respawn_player()
	else:
		_on_game_over()

func _respawn_player() -> void:
	if is_paused: 
		return
	# Limpia balas/enemigos cercanos si quieres dar “respiro”
	# _spawner.clear_near_player()  # si implementas algo así
	_spawn_player()

# ---------------------------
# Score y destrucciones
# ---------------------------
# Estas funciones las invocan Asteroids/UFO/Spawner cuando algo muere.
func on_asteroid_destroyed(points: int = 100) -> void:
	score += points
	_update_ui_score()
	_check_wave_cleared()

func on_ufo_destroyed(points: int = 250) -> void:
	score += points
	_update_ui_score()
	_check_wave_cleared()

func _check_wave_cleared() -> void:
	# Regla simple: pregunta al Spawner si quedan enemigos/asteroides
	if _spawner and _spawner.has_method("is_wave_cleared"):
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
func _on_game_over() -> void:
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
func _update_ui_all() -> void:
	_update_ui_score()
	_update_ui_lives()
	_update_ui_wave()
	_update_ui_pause()

func _update_ui_score() -> void:
	if not _ui:
		return
	var score_label := _ui.get_node_or_null("HUD/ScoreLabel")
	if score_label and score_label.has_method("set_text"):
		score_label.set_text(str(score))

func _update_ui_lives() -> void:
	if not _ui:
		return
	var lives_label := _ui.get_node_or_null("HUD/LivesLabel")
	if lives_label and lives_label.has_method("set_text"):
		lives_label.set_text(str(lives))

func _update_ui_wave() -> void:
	if not _ui:
		return
	var wave_label := _ui.get_node_or_null("HUD/WaveLabel")
	if wave_label and wave_label.has_method("set_text"):
		wave_label.set_text(str(wave_index + 1))

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
