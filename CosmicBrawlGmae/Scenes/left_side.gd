extends Area2D

@onready var camera: Camera2D = $".."
@onready var left_side: Area2D = $"."

var player_in_area: bool = false 
var stop = false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = true
		Globals.in_left_camera = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_area = false
		Globals.in_left_camera = false

func _process(delta: float) -> void:
	if player_in_area and camera: 
		camera.zoom -= Vector2(Globals.camera_slide, Globals.camera_slide) * delta 
		left_side.position.x -= 0.1
	elif Globals.in_center_camera and not Globals.in_right_camera and not stop:
		left_side.position.x += 0.1

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Center":
		stop = true

func _on_area_exited(area: Area2D) -> void:
	if area.name == "Center":
		stop = false
