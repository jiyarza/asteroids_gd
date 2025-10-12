extends RigidBody2D
class_name Player

@export var input: PlayerInput
@export var physics: ShipPhysics
@export var weapon: Weapon

func _ready() -> void:
	# Inyecta en los componentes los valores existentes del Player (si los pones aquí)
	if physics:
		physics.input = input

	if weapon:
		if input:
			weapon.connect_input(input)
