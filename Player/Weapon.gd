extends Node
class_name Weapon

signal fire_requested(position: Vector2, direction: Vector2, config: Dictionary)

@export var muzzle: Node2D
@export var cooldown: Timer
@export var muzzle_impulse := 800.0
@export var inherit_ship_velocity := true

#var _cool := 0.0
var _ship: RigidBody2D

func _ready():
	_ship = get_parent() as RigidBody2D
	assert(_ship and muzzle)

#func _process(dt):
	#_cool = max(0.0, _cool - dt)

func connect_input(pi: PlayerInput):
	pi.shoot_pressed.connect(_on_shoot)

func _on_shoot():
	if cooldown.time_left > 0.0:
		return
		
	var forward := -muzzle.global_transform.y.normalized()

	# Emitimos la petición de disparo para que el Spawner instancie
	var cfg := {
		"speed": 600.0,                     # opcional; Spawner tiene default_bullet_speed
		"inherit_velocity": inherit_ship_velocity,
		"muzzle_impulse": muzzle_impulse
	}
	emit_signal("fire_requested", muzzle.global_position, forward, cfg)			
 
