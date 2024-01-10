extends ColorRect


func _ready():
	randomize()
	Globals.music_player.play()


func _on_Play_pressed():
	Globals.music_player.stop()
	Globals.goto_scene("res://Scenes/Levels/LevelBase/LevelBase.tscn", { 'level': 1 })


func _on_Exit_pressed():
	get_tree().quit()
