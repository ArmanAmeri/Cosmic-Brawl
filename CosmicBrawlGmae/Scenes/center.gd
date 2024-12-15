extends Area2D

@onready var camera: Camera2D = $".."
@onready var center: Area2D = $"."


var player_in_area: bool = false 
var stop = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = true
		Globals.in_center_camera = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = false
		Globals.in_center_camera = false

func _process(delta: float) -> void:
	if player_in_area and camera: 
		camera.zoom += Vector2(Globals.camera_slide, Globals.camera_slide) * delta 
	elif not Globals.in_center_camera and not stop:
		center.scale.x += 0.0005
	

func _on_area_entered(area: Area2D) -> void:
	if area.name == "LeftSide":
		stop = true
	elif area.name == "RightSide":
		stop = true


func _on_area_exited(area: Area2D) -> void:
	if area.name == "LeftSide":
		stop = false
	elif area.name == "RightSide":
		stop = false
