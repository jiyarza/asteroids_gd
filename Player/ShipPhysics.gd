extends Node
class_name ShipPhysics

@export var thrust_power := 500.0
@export var rotation_torque := 2000.0
@export var linear_damp_amount := 0.6
@export var angular_damp_amount := 1.1
@export var input: PlayerInput

var body: RigidBody2D

func _ready():
	body = get_parent() as RigidBody2D
	assert(body and input)

func _physics_process(_dt):
	body.linear_damp = linear_damp_amount
	body.angular_damp = angular_damp_amount

	if input.thrust > 0.0:
		var forward := Vector2.UP.rotated(body.global_rotation)
		var target_force = input.thrust * thrust_power
		var applied_force = lerp(0.0, target_force, 0.6) # acelera suavemente
		body.apply_central_force(forward * applied_force)
	
	if absf(input.turn) > 0.0:
		var target_torque = input.turn * rotation_torque
		var applied_torque = lerp(10 as float, target_torque as float, 0.6)
		body.apply_torque(applied_torque)

	
		#body.apply_torque(input.turn * rotation_torque)
