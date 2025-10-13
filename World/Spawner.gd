# Spawner.gd (Godot 4)
extends Node2D
class_name Spawner

@export_node_path("Node2D") var world_path: NodePath
# =======================
# Escenas a instanciar
# =======================
@export var bullet_scene: PackedScene
@export var asteroid_large_scene: PackedScene
@export var asteroid_medium_scene: PackedScene
@export var asteroid_small_scene: PackedScene
@export var ufo_scene: PackedScene

# =======================
# Config de oleadas
# =======================
@export var base_large_asteroids: int = 4
@export var asteroids_per_wave_increment: int = 2
@export var min_spawn_distance_from_player: float = 220.0
@onready var _world: Node = get_node(world_path)

func _ready() -> void:
	randomize()
	
# ======================================================
# Conectar armas (Weapon) para que Spawner instancie balas
# ======================================================
func connect_weapon(weapon: Node) -> void:
	# Weapon debe emitir: signal fire_requested(position, direction, config)
	if weapon and weapon.has_signal("fire_requested"):
		weapon.fire_requested.connect(_on_weapon_fire_requested)

func _on_weapon_fire_requested(pos: Vector2, dir: Vector2) -> void:	
	spawn_bullet(pos, dir)

# =======================
# Limpieza del mundo (sólo grupo "spawn")
# =======================
func clear_world() -> void:
	for n in get_tree().get_nodes_in_group("spawn"):
		if is_instance_valid(n):
			n.queue_free()

# ==============
# Bullets
# ==============
func spawn_bullet(spawn_position: Vector2, direction: Vector2) -> Node:
	if bullet_scene == null:
		push_warning("Spawner.spawn_bullet: scene es null.")
		return null
	var bullet := bullet_scene.instantiate()
	_world.add_child(bullet)
	bullet.setup(spawn_position, direction)
	bullet.add_to_group("spawn")     # 👈 clave
	bullet.add_to_group("bullets")		
	
	return bullet

# ==============
# Asteroides
# ==============
enum AstSize { LARGE, MEDIUM, SMALL }

func spawn_asteroid(size: int, spawn_position: Vector2, velocity: Vector2 = Vector2.ZERO) -> Node:
	var scene: PackedScene = null
	match size:
		AstSize.LARGE:
			scene = asteroid_large_scene
		AstSize.MEDIUM:
			scene = asteroid_medium_scene
		AstSize.SMALL:
			scene = asteroid_small_scene
		_:
			scene = null

	if scene == null:
		push_warning("Spawner.spawn_asteroid: escena no asignada para tamaño %s" % [str(size)])
		return null

	var asteroid := scene.instantiate()
	asteroid.global_position = spawn_position

	if asteroid is RigidBody2D:
		asteroid.linear_velocity = velocity
	elif asteroid.has_method("set_velocity"):
		asteroid.set_velocity(velocity)

	asteroid.add_to_group("spawn")   # 👈 clave
	asteroid.add_to_group("asteroids")
	if not _world:
		_world = get_node(world_path)
	
	_world.call_deferred("add_child", asteroid)
	
	return asteroid

# ==============
# UFO (opcional)
# ==============
func spawn_ufo(spawn_position: Vector2) -> Node:
	if ufo_scene == null:
		push_warning("Spawner.spawn_ufo: ufo_scene no asignado.")
		return null
	var ufo := ufo_scene.instantiate()
	ufo.global_position = spawn_position
	ufo.add_to_group("spawn")        # 👈 clave
	ufo.add_to_group("enemies")
	_world.add_child(ufo)
	return ufo

# ===========================
# Oleadas básicas de asteroides
# ===========================
func spawn_wave(wave_index: int, player_global_pos: Vector2 = Vector2.ZERO) -> void:
	var count := base_large_asteroids + wave_index * asteroids_per_wave_increment
	var viewport_size := get_viewport().get_visible_rect().size
	for i in range(count):
		var pos := _random_pos_away_from(player_global_pos, viewport_size, min_spawn_distance_from_player)
		var vel := _random_asteroid_velocity()
		spawn_asteroid(AstSize.LARGE, pos, vel)

# ¿Se ha limpiado la oleada?
func is_wave_cleared() -> bool:
	return (
		get_tree().get_nodes_in_group("asteroids").is_empty()
		and get_tree().get_nodes_in_group("enemies").is_empty()
	)

# ===========================
# Helpers internos
# ===========================
func _random_pos_away_from(center: Vector2, viewport_size: Vector2, min_dist: float) -> Vector2:
	var attempts := 0
	while attempts < 20:
		var p := Vector2(randf() * viewport_size.x, randf() * viewport_size.y)
		if p.distance_to(center) >= min_dist:
			return p
		attempts += 1
	return Vector2(randf() * viewport_size.x, randf() * viewport_size.y)

func _random_asteroid_velocity() -> Vector2:
	var speed := randf_range(60.0, 140.0)
	var angle := randf_range(0.0, TAU)
	return Vector2.RIGHT.rotated(angle) * speed
