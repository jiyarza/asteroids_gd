extends Node
class_name PauseController

@export var pause_label: CanvasItem

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		if pause_label:
			pause_label.visible = get_tree().paused
