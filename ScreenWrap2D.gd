# ScreenWrap2D.gd
extends Node
class_name ScreenWrap2D

@export var margin := 0.0

var _node: Node2D
var _is_rigid := false
var _screen: Vector2

func _ready():
	_node = get_parent() as Node2D
	_is_rigid = _node is RigidBody2D
	_screen = _node.get_viewport_rect().size

func _physics_process(_dt):
	var p := _node.global_position
	var wrapped := false

	if p.x > _screen.x + margin: p.x = -margin; wrapped = true
	elif p.x < -margin: p.x = _screen.x + margin; wrapped = true
	if p.y > _screen.y + margin: p.y = -margin; wrapped = true
	elif p.y < -margin: p.y = _screen.y + margin; wrapped = true

	if wrapped:
		if _is_rigid:
			_node.call_deferred("set_global_position", p)
		else:
			_node.global_position = p
