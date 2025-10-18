extends Control
class_name HUD

@onready var lives_label: Label = $MarginContainer/HBoxContainer/LivesLabel
@onready var level_label: Label = $MarginContainer/HBoxContainer/LevelLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel

var _life_icon := "▲" # Triángulo UP (U+25B2)

func set_lives(n: int) -> void:
	if not lives_label:
		return
	n = max(n, 0)
	lives_label.text = "Vidas: " + _life_icon.repeat(n)

func set_level(n: int) -> void:
	if level_label:
		level_label.text = "Level %d" % n

func set_score(s: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % s

func reset(score := 0, lives := 3, level := 1) -> void:
	set_score(score)
	set_lives(lives)
	set_level(level)
