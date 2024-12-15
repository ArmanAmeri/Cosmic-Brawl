extends Control


func _on_play_button_up() -> void:
	Globals.P1lives = 3
	Globals.P2lives = 3
	get_tree().change_scene_to_file("res://Scenes/MainGame.tscn")
