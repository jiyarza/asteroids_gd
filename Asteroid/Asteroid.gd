extends RigidBody2D
class_name Asteroid

# Variables exportadas para poder ajustarlas desde el editor
@export var speed: float = 10.0
@export var rotation_speed: float = 0.3

var direction: Vector2 = Vector2.UP # Dirección inicial por defecto

func _ready():
	# Al empezar, elegimos una rotación aleatoria
	rotation = randf() * TAU # TAU es 2*PI, una rotación completa

func _process(delta):
	# Movemos el asteroide en su dirección
	position += direction * speed * delta
	
	# Rotamos el asteroide sobre sí mismo
	rotation += rotation_speed * delta

# Función para configurar el asteroide cuando lo creamos
func setup(start_position: Vector2, start_direction: Vector2, start_size: float = 1.0):
	position = start_position
	direction = start_direction.normalized() # Aseguramos que la dirección sea un vector unitario
	
	# Escalamos el asteroide
	scale = Vector2(start_size, start_size)
	
	# Ajustamos la velocidad según el tamaño (los más pequeños son más rápidos)
	speed = speed / start_size
