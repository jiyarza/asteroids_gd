extends Node
class_name PlayerInput

signal shoot_pressed

var thrust: float = 0.0     # 0..1
var turn: float = 0.0       # -1..1

func _process(_dt):
	thrust = Input.get_action_strength("thrust")
	turn = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	if Input.is_action_just_pressed("shoot"):
		shoot_pressed.emit()
