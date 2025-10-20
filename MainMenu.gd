extends Node2D

@onready var title_label: Label = $CanvasLayer/TitleLabel
@onready var start_label: Label = $CanvasLayer/StartLabel
@onready var anim: AnimationPlayer = $CanvasLayer/AnimationPlayer

func _ready() -> void:
	anim.play("title_intro")
	anim.queue("blink") # empezará automáticamente al terminar title_intro


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		# Detectar tecla ESC → salir del juego
		if event is InputEventKey and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		else:
			# Cualquier otra tecla → empezar el juego
			_start_game()

func _start_game() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")
