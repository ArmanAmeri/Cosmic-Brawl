extends Node2D

signal victory()
signal counterChange()

var victoryBool: bool = false 

func _on_player_player_died() -> void:
	if not victoryBool:
		Globals.P1lives -= 1
	counterChange.emit()
	victoryBool = true
	victory.emit()
	await get_tree().create_timer(3).timeout
	if Globals.P1lives <= 0:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		get_tree().reload_current_scene()


func _on_player_2_player_died() -> void:
	if not victoryBool:
		Globals.P2lives -= 1
	counterChange.emit()
	victoryBool = true
	victory.emit()
	await get_tree().create_timer(3).timeout
	if Globals.P2lives <= 0:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		get_tree().reload_current_scene()
