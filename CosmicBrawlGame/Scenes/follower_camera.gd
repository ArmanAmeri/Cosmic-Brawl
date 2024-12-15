extends Camera2D

# Minimum and maximum zoom levels
@export var min_zoom: float = 2.0
@export var max_zoom: float = 6.0
@export var max_distance: float = 500.0

@onready var camera: Camera2D = $"."


# Smoothing factors
@export var position_smoothing: float = 45.0  # Higher value = faster smoothing
@export var zoom_smoothing: float = 5.0      # Higher value = faster zoom smoothing

# Target values
var target_position: Vector2
var target_zoom: Vector2 = Vector2.ONE

func _process(delta):
	var player_positions = []
	for player in get_tree().get_nodes_in_group("players"):
		if player.is_inside_tree():
			player_positions.append(player.global_position)
	
		if get_tree().get_nodes_in_group("players").size() == 1:
			camera.position = player.position
	
	if player_positions.size() == 0:
		return  # No players, no camera adjustment
	
	# Calculate target position (center between players)
	target_position = calculate_center(player_positions)
	
	# Smoothly move the camera towards the target position
	global_position = global_position.move_toward(target_position, position_smoothing * delta)
	
	# Calculate the maximum distance between players and adjust zoom
	var max_dist = calculate_max_distance(player_positions)
	var target_zoom_factor = lerp(max_zoom, min_zoom, max_dist / max_distance)  # Reversed logic
	target_zoom = Vector2(target_zoom_factor, target_zoom_factor)
	
	# Smoothly interpolate zoom
	zoom = zoom.lerp(target_zoom, zoom_smoothing * delta)

func calculate_center(positions: Array) -> Vector2:
	var sum = Vector2.ZERO
	for pos in positions:
		sum += pos
	return sum / positions.size()

func calculate_max_distance(positions: Array) -> float:
	var max_dist = 0.0
	for i in range(positions.size()):
		for j in range(i + 1, positions.size()):
			var dist = positions[i].distance_to(positions[j])
			if dist > max_dist:
				max_dist = dist
	return max_dist
