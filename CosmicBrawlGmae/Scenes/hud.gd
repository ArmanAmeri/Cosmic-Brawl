extends CanvasLayer

@onready var health_bar_right: TextureProgressBar = $HealthBarRight
@onready var health_bar_left: TextureProgressBar = $HealthBarLeft
@onready var player_1_life: Label = $Counter/Player1Life
@onready var player_2_life: Label = $Counter/Player2Life
@onready var victory_log: Label = $VictoryLog

func _ready() -> void:
	player_1_life.text = str(Globals.P1lives)
	player_2_life.text = str(Globals.P2lives)

func _on_player_player_update_health(color: Variant) -> void:
	health_bar_left.tint_progress = color
		

func _on_player_2_player_update_health(color: Variant) -> void:
	health_bar_right.tint_progress = color


func _on_main_scene_victory() -> void:
	victory_log.visible = true


func _on_main_scene_counter_change() -> void:
	player_1_life.text = str(Globals.P1lives)
	player_2_life.text = str(Globals.P2lives)
