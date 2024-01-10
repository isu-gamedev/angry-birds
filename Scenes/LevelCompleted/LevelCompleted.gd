extends Control

onready var score := $NinePatchRect/ScoreWrapper/Score
onready var retry_button := $NinePatchRect/VBoxContainer/Retry
onready var menu_button := $NinePatchRect/VBoxContainer/Menu


func _ready():
	pass


func appear(final_score: int):
	score.score_value = final_score
	$AnimationPlayer.play("show")
	yield($AnimationPlayer, "animation_finished")
	retry_button.disabled = false
	menu_button.disabled = false


func _animate_score():
	score.appear_animation()


func _on_Retry_pressed():
	Globals.goto_scene("res://Scenes/Levels/LevelBase/LevelBase.tscn", {'level': Globals.current_level_index})


func _on_Menu_pressed():
	Globals.goto_scene("res://Scenes/MainMenu/MainMenu.tscn")
