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
			
	call_deferred("_center")
	
func _center() -> void:
	global_position = get_viewport().get_visible_rect().size / 2
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
