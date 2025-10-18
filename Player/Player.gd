extends RigidBody2D
class_name Player

@export var input: PlayerInput
@export var physics: ShipPhysics
@export var weapon: Weapon

signal died
@export var invulnerability_time := 1.25
var _invulnerable := false
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	physics.input = input
	weapon.connect_input(input)	
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)

	call_deferred("_center")
	
func _center() -> void:
	global_position = get_viewport().get_visible_rect().size / 2
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	
# ➕ MANEJADOR DE COLISIÓN
func _on_hurtbox_body_entered(body: Node) -> void:
	print("_on_hurtbox_body_entered ", body)
	if _invulnerable:
		return
	# Asteroid tiene class_name Asteroid, así que podemos hacer 'is Asteroid'
	if body is Asteroid:
		_die()
		
# ➕ LÓGICA DE MUERTE
func _die() -> void:
	emit_signal("died")
	# Aquí puedes disparar VFX/SFX antes de desaparecer
	queue_free()
	
# Llamar a esto desde GameManager al respawnear para invulnerabilidad inicial
func enable_spawn_invulnerability() -> void:
	_invulnerable = true
	if hurtbox:
		hurtbox.monitoring = false
	# Pequeño "blink" visual
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.3, 0.1).set_trans(Tween.TRANS_SINE)
	t.tween_property(self, "modulate:a", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_loops( int(invulnerability_time / 0.2) )
	await get_tree().create_timer(invulnerability_time).timeout
	if is_instance_valid(self):
		modulate.a = 1.0
		_invulnerable = false
		if hurtbox:
			hurtbox.monitoring = true
