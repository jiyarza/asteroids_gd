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

# Velocidad por defecto de bala (si el arma no la especifica)
@export var default_bullet_speed: float = 600.0

var _world: Node2D

func _ready() -> void:
	_world = _get_world()
	
	randomize()

func _get_world() -> Node2D:
	# 1) Por export
	if world_path != NodePath(""):
		_world = get_node(world_path) as Node2D

	# 2) Si no hay export, intenta por nombre dentro de la escena actual
	if _world == null and get_tree().current_scene and get_tree().current_scene.has_node("World"):
		_world = get_tree().current_scene.get_node("World") as Node2D

	# 3) Como último recurso, por grupo "world" (si lo usas)
	if _world == null:
		_world = get_tree().get_first_node_in_group("world") as Node2D

	# 4) Fallback extremo: si el Spawner es hijo directo de World, úsalo; si no, self
	if _world == null:
		_world = get_parent() as Node2D
	
	if _world == null:
		push_error("Spawner: no encuentro el nodo 'World'. Asigna 'world_path' o añade el nodo al grupo 'world'.")
		_world = self  # evita null y al menos instancia en el propio Spawner

	return _world
	
# ======================================================
# Conectar armas (Weapon) para que Spawner instancie balas
# ======================================================
func connect_weapon(weapon: Node) -> void:
	# Weapon debe emitir: signal fire_requested(position, direction, config)
	if weapon and weapon.has_signal("fire_requested"):
		weapon.fire_requested.connect(_on_weapon_fire_requested)

func _on_weapon_fire_requested(pos: Vector2, dir: Vector2, cfg: Dictionary) -> void:	
	var speed: float = float(cfg.get("speed", default_bullet_speed))
	spawn_bullet(pos, dir, bullet_scene, speed)

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
func spawn_bullet(spawn_position: Vector2, direction: Vector2, scene: PackedScene = bullet_scene, speed: float = default_bullet_speed) -> Node:
	print("spawn_bullet() - called")
	if scene == null:
		push_warning("Spawner.spawn_bullet: scene es null.")
		return null
	var bullet := scene.instantiate()
	bullet.global_position = spawn_position
	bullet.rotation = direction.angle()

	# Inicialización flexible según el tipo de Bullet:
	if bullet.has_method("initialize"):
		bullet.initialize(direction.normalized() * speed)
	elif bullet is RigidBody2D:
		bullet.linear_velocity = direction.normalized() * speed
	elif bullet.has_method("set_velocity"):
		bullet.set_velocity(direction.normalized() * speed)

	bullet.add_to_group("spawn")     # 👈 clave
	bullet.add_to_group("bullets")
	#_world.call_deferred("add_child", bullet)
	_world.add_child(bullet)
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
		_get_world()
			
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
