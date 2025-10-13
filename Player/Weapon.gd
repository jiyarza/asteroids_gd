extends Node
class_name Weapon

signal fire_requested(position: Vector2, direction: Vector2, config: Dictionary)

@export var muzzle: Node2D
@export var cooldown: Timer
@export var speed := 600.0
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
	if !cooldown.is_stopped():
		return
		
	var forward := -muzzle.global_transform.y.normalized()
	emit_signal("fire_requested", muzzle.global_position, forward)
	cooldown.start()
 
