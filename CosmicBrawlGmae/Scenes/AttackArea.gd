extends Area2D

@export var attack_facing_direction: Vector2 = Vector2.RIGHT  # Default facing direction

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("onHit") and body.is_in_group("players"):
		# Calculate knockback direction based on the attack's facing direction
		var hit_direction = attack_facing_direction.normalized()

		if Globals.attackType == 1:
			body.onHit(hit_direction, (body.strength_knockback / 1.5), Globals.playerDamage)
		elif Globals.attackType == 2:
			body.onHit(hit_direction, (body.strength_knockback * 1.2), Globals.playerHeavyDamage)
