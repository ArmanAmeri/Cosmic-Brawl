extends Node2D

@onready var spawn_rate: Timer = $SpawnRate
@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

@export var min_spawn_cooldown = 5
@export var max_spawn_cooldown = 10

var layer = 1 
var spawn_positions: Array[Vector2] = [] 

var LoadItem = load("res://Scenes/pickup_item.tscn")
var Items = ["power up", "chance"]

func _ready():
	for cell in tile_map_layer.get_used_cells():
		if has_air_access(cell):
			var global_pos = tile_map_layer.to_global(tile_map_layer.map_to_local(cell))
			spawn_positions.append(global_pos + Vector2(0, -40))
			#print("Tile with air access at tilemap coordinate ", cell, " is at global position: ", global_pos)


func has_air_access(tile_coord: Vector2i) -> bool:
	var direction_up = Vector2i(0, -1) 
	var first_above_coord = tile_coord + direction_up
	var second_above_coord = first_above_coord + direction_up
	
	if not tile_map_layer.get_cell_tile_data(first_above_coord) and not tile_map_layer.get_cell_tile_data(second_above_coord):
		return true

	return false

func spawn_entities():
	var pos = randomListIndex(spawn_positions)
	var item = LoadItem
	var current_item = item.instantiate()
	current_item.item_name = randomListIndex(Items)
	current_item.global_position = pos
	get_parent().get_node("ItemGroup").add_child(current_item)


func randomListIndex(list):
	var rng = RandomNumberGenerator.new()

	var random_index = rng.randi_range(0, list.size() - 1)

	var random_element = list[random_index]
	
	return random_element



func _on_spawn_rate_timeout() -> void:
	spawn_entities()
	var rng = RandomNumberGenerator.new()
	var cooldown = rng.randi_range(min_spawn_cooldown, max_spawn_cooldown)
	spawn_rate.wait_time = cooldown
