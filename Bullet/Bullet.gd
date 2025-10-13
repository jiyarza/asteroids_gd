extends Area2D
class_name Bullet
# Velocidad de la bala. @export para poder ajustarla en el Inspector.
@export var speed = 600.0

# Variable para guardar la dirección en la que se moverá la bala.
var direction = Vector2.UP

# Referencia al nodo Timer que añadimos.
@onready var lifetime_timer = $Timer

func setup(start_pos: Vector2, start_dir: Vector2) -> void:
	direction = start_dir.normalized()
	print("start_pos", start_pos)
	global_position = start_pos
	global_rotation = direction.angle()
	print("bullet pos: ", global_position)

# Función que se llama cuando la bala entra en la escena.
func _ready():
	z_index = 100              # por si queda detrás de algo
	visible = true
	modulate.a = 1.0
	queue_redraw()  
	# Conectamos la señal 'timeout' del Timer a nuestra función _on_lifetime_timeout.
	lifetime_timer.timeout.connect(_on_lifetime_timeout)

	# Conectamos la señal 'body_entered' para saber si choca con algo.
	body_entered.connect(_on_body_entered)

# Se llama en cada frame. Ideal para el movimiento.
func _physics_process(delta):
	# Movemos la bala en su dirección.
	# Usamos 'global_position' para asegurarnos de que se mueve correctamente
	# independientemente de si la cámara se mueve o no.
	global_position += direction * speed * delta

# --- Funciones de Señal (Callbacks) ---

# Esta función se ejecutará cuando el Timer llegue a 0.
func _on_lifetime_timeout():
	# La bala ha vivido suficiente, la destruimos.
	queue_free()

# Esta función se ejecutará cuando el Area2D de la bala toque un cuerpo físico (RigidBody, CharacterBody...).
func _on_body_entered(_body):
	print("Bullet: _on_body_entered")
	# Por ahora, simplemente destruimos la bala al impactar.
	# Más adelante, aquí le diremos al asteroide que se destruya.
	queue_free()
