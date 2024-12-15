extends RigidBody2D  

@export var item_name: String = "Default Item"  
@export var amount: int = 1                   

const NITRO_TEXTURE = preload("res://Sprites/NitroOrb.png")
const COUNTER_TEXTURE = preload("res://Sprites/counter.png")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("collect_item"): 
		body.collect_item(item_name, amount) 
		queue_free()

func _ready() -> void:
	if item_name == "power up":
		$Sprite2D.texture = NITRO_TEXTURE
	elif item_name == "chance":
		$Sprite2D.texture = COUNTER_TEXTURE
