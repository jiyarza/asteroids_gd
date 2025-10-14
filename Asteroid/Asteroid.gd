extends RigidBody2D
class_name Asteroid

signal split_requested(world_position: Vector2, next_size: int)
signal destroyed(world_position: Vector2, size: int)

enum Size { LARGE, MEDIUM, SMALL } 
# Variables exportadas para poder ajustarlas desde el editor
@export var size = Size.LARGE
@export var min_speed: float = 10.0
@export var max_speed: float = 50.0
@export var min_impulse: float = 10.0
@export var max_impulse: float = 50.0
@export var min_torque: float = -20.0
@export var max_torque: float = 20.0
@export var speed: float = 0.0

var target_speed = 50.0;
var torque_value = 0.0;
var direction: Vector2 = Vector2.UP # Dirección inicial por defecto

func _ready() -> void:
	# Configuración física: sin pérdidas ni sueño
	gravity_scale = 0.0
	linear_damp = 0.0
	angular_damp = 0.0
	can_sleep = false

	# Material sin fricción, con rebote elástico
	if physics_material_override == null:
		physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = 0.0
	physics_material_override.bounce = 1.0

	# Dirección y magnitud inicial aleatorias
	direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
	target_speed = randf_range(min_speed, max_speed)
	linear_velocity = direction * target_speed

	# Torque aleatorio (mantiene rotación continua)
	torque_value = randf_range(min_torque, max_torque)

# Mantener la velocidad constante, respetando dirección tras colisiones
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var v := state.linear_velocity
	var s := v.length()

	if s <= 0.001:
		# Si se detiene completamente, reimpulsar en dirección aleatoria
		var dir = Vector2.RIGHT.rotated(randf_range(0.0, TAU))
		state.linear_velocity = dir * target_speed
	else:
		# Reescalar para mantener velocidad constante
		state.linear_velocity = v * (target_speed / s)

	# Mantener el torque constante (rotación continua)
	state.apply_torque(torque_value)

#func _process(delta):
#	return
	# Movemos el asteroide en su dirección
	#position += direction * speed * delta
	
	# Rotamos el asteroide sobre sí mismo
	#rotation += rotation_speed * delta

# Función para configurar el asteroide cuando lo creamos
func setup(start_position: Vector2, start_direction: Vector2, start_size: float = 1.0):
	position = start_position
	direction = start_direction.normalized() # Aseguramos que la dirección sea un vector unitario
	
	# Escalamos el asteroide
	scale = Vector2(start_size, start_size)
	
	# Ajustamos la velocidad según el tamaño (los más pequeños son más rápidos)
	speed = speed / start_size

func hit():
	# Si ya es el tamaño mínimo, desaparece
	if size == Size.SMALL:
		print("Asteroid DESTROYED")
		destroyed.emit(global_position, size)
		queue_free()
		return

	# Determina el siguiente tamaño
	var next_size
	if size == Size.LARGE:
		next_size = Size.MEDIUM
	else:
		next_size = Size.SMALL
	
	split_requested.emit(global_position, next_size)
	# El asteroide original desaparece
	queue_free()
