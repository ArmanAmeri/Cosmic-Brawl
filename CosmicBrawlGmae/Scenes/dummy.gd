extends CharacterBody2D

@export var hp = 500
@onready var hp_bar: TextureProgressBar = $HPBar
@onready var animation: AnimationPlayer = $AnimationPlayer
var is_dead = false

func _ready() -> void:
	hp_bar.max_value = hp
	hp_bar.value = hp

func _physics_process(_delta: float) -> void:
	animation.play("idle")
	if hp <= 0:
		die()

func onHit(damage):
	hp -= damage
	hp_bar.value = hp
	
	
# This function is called when the enemy dies
func die():
	is_dead = true
	print("Enemy Felled")
	#emit_signal("enemy_died")  # Emit signal if needed for other game events (e.g., score)
	# You can play a death animation or sound here (optional)
	queue_free()  # This removes the enemy node from the scene
