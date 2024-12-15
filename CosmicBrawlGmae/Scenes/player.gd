extends CharacterBody2D

class_name Player

signal player_update_health(color)
signal playerDied()

@onready var player_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_coll: CollisionShape2D = $PlayerColl
@onready var player: CharacterBody2D = $"."


@export var speed = 100.0
@export var jump_velocity = -300.0
@export var gravity: float = 1
@export var player_id = 1

@export var hp: int = 0  # Set unique health for each player in the editor

var is_dead: bool = false

@onready var hp_bar: TextureProgressBar = $HPBar

@onready var animation: AnimationPlayer = $AnimationPlayer

@onready var attack: Sprite2D = $AttackArea/attack
@onready var attack_cooldown: Timer = $Timers/AttackCooldown
@onready var attack_timer: Timer = $Timers/AttackTimer

@onready var heavy_attack: Sprite2D = $AttackArea/heavyAttack
@onready var heavy_cooldown: Timer = $Timers/HeavyCooldown

@onready var heavy_charge_time: Timer = $Timers/HeavyChargeTime
@onready var charge_bar: TextureProgressBar = $PlayerBack/ChargeBar
@onready var charge_orb: TextureProgressBar = $PlayerBack/ChargeOrb


@onready var attack_pause: Timer = $Timers/attackPause
@onready var orb_cooldown: Timer = $Timers/OrbCooldown
@onready var heavy_buff: Timer = $Timers/HeavyBuff


@onready var dash_cooldown: Timer = $Timers/DashCooldown
@onready var dash_timer: Timer = $Timers/DashTimer

@onready var player_back: Node2D = $PlayerBack


@export var attackSpeedRange: float = 300
@export var heavyAttackSpeedRange: float = 300

@onready var n: Marker2D = $player_cardinalDirections/N
@onready var s: Marker2D = $player_cardinalDirections/S
@onready var w: Marker2D = $player_cardinalDirections/W
@onready var e: Marker2D = $player_cardinalDirections/E

@onready var attackArea: Area2D = $AttackArea
@onready var attack_coll: CollisionShape2D = $AttackArea/AttackColl


var attacking = false
var dashing = false
var canDash = true
var looking_right: bool = true
var canAttack: bool = true

var heavyCanAttack: bool = true
var heavyCharge = 0
var heavyAttacking = false
var heavyCharging = false

var canChangeDirection = true
var locked_direction: int = 1  # 1 for right, -1 for left

var canDoubleJump: bool = true
var canDashAttackJump: bool = true
var canDashAttackJump2: bool = true

var A: String = "A_%s" % player_id
var D: String = "D_%s" % player_id
var S: String = "S_%s" % player_id
var W: String = "W_%s" % player_id
var Dash: String = "Dash_%s" % player_id
var Jump: String = "Jump_%s" % player_id
var Attack: String = "Attack_%s" % player_id
var HeavyAttack: String = "HeavyAttack_%s" % player_id
var Charge: String = "ChargeHeavyAttack_%s" % player_id

var invincible: bool = false

var knockback_vector: Vector2 = Vector2.ZERO
var knockback_strength: float = 0.0
var knockback_decay_rate: float = 1250.0

var HPM1: float = 350.0
var HPM2: float = 400.0
var HPM3: float = 450.0
var HPM4: float = 550.0
var HPM5: float = 700.0
var HPM6: float = 1000.0
var HPM7: float = 1500.0

var strength_knockback: float = HPM1 #1 Level: 350, 2 Level 400, 3 Level 450, 4 Level 550, 5 Level 700, 6 Level 1000, 7 Level 1500

var chanceOption = null

func _ready() -> void:
	attack.visible = false
	heavy_attack.visible = false
	charge_bar.visible = false
	charge_orb.visible = false
	attack_coll.disabled = true
	hp_bar.tint_progress = Color(255/ 255.0, 255/ 255.0, 255/ 255.0)
	if player_id == 1:
		attackArea.set_collision_layer_value(2, true)
		attackArea.set_collision_layer_value(5, false)
		attackArea.set_collision_mask_value(2, false)
		attackArea.set_collision_mask_value(5, true)
		
		player.set_collision_layer_value(2, true)
		player.set_collision_layer_value(5, false)
	if player_id == 2:
		attackArea.set_collision_layer_value(2, false)
		attackArea.set_collision_layer_value(5, true)
		attackArea.set_collision_mask_value(2, true)
		attackArea.set_collision_mask_value(5, false)
		
		player.set_collision_layer_value(2, false)
		player.set_collision_layer_value(5, true)
	
	if player_id == 2:
		player_sprite.modulate = Color(0, 0, 1)
	
	

func _physics_process(delta: float) -> void:
	
	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * gravity
	
	A = "A_%s" % player_id
	D = "D_%s" % player_id
	S = "S_%s" % player_id
	W = "W_%s" % player_id
	Dash = "Dash_%s" % player_id
	Jump = "Jump_%s" % player_id
	Attack = "Attack_%s" % player_id
	HeavyAttack = "HeavyAttack_%s" % player_id
	Charge = "ChargeHeavyAttack_%s" % player_id
	
	if Input.is_action_pressed(Charge):
		heavyCharging = true
		charge_bar.visible = true
		charge_orb.visible = true
		charge_bar.value += 1
		speed = 25
		gravity = 3
		if charge_bar.value == charge_bar.max_value:
			if heavyCharge < 3:
				heavyCharge += 1
			charge_bar.value = 0
		if heavyCharge == 3:
			charge_bar.value = 0
	else:
		heavyCharging = false
		charge_bar.value = 0
		charge_bar.visible = false
		if orb_cooldown.is_stopped():
			charge_orb.visible = false
		speed = 100
		gravity = 1
	
	charge_orb.value = heavyCharge
	
	# Handle jump
	if (Input.is_action_just_pressed(W) or Input.is_action_just_pressed(Jump)) and (is_on_floor() or canDoubleJump):
		velocity.y = jump_velocity
		canDoubleJump = false
	
	if is_on_floor():
		canDoubleJump = true
		canDashAttackJump = true
		canDashAttackJump2 = true
		
	
	if Input.is_action_just_pressed(Dash) and canDash:
		dashing = true
		canDash = false
		dash_cooldown.start()
		dash_timer.start()
	
	
	# Handle movement input
	var direction = Input.get_axis(A, D)

	if not canChangeDirection:
		# Lock movement to the currently stored direction
		direction = locked_direction
	elif direction != 0:
		# Update the locked direction when direction changes
		locked_direction = 1 if direction > 0 else -1

	if dashing:
		# Dashing ignores locking but respects input or defaults to facing direction
		velocity.x = direction * Globals.dash if direction != 0 else locked_direction * Globals.dash
		velocity.y = 0
		invincible = true
	elif heavyAttacking:
		velocity.x = direction * heavyAttackSpeedRange
	else:
		# Regular movement
		invincible = false
		if direction != 0:
			velocity.x = direction * speed
			if canChangeDirection:
				looking_right = direction > 0
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	# Update animations based on state
	if dashing:
		player_sprite.play("dash")
	elif not is_on_floor():
		player_sprite.play("jump_right" if looking_right else "jump_left")
	elif direction != 0:
		player_sprite.play("run_right" if looking_right else "run_left")
	else:
		player_sprite.play("idle_right" if looking_right else "idle_left")


	player_back.scale.x = -1 if not looking_right else 1
	
#	if looking_right:
#		attack.flip_h = false
#		attack_area.position.x = 0
#		heavy_attack.flip_h = false
#		heavy_attack_area.position.x = 0
#		player_back.position.x = -10
#		
#	else:
#		attack.flip_h = true
#		attack_area.position.x = -24
#		heavy_attack.flip_h = true
#		heavy_attack_area.position.x = -29
#		player_back.position.x = 10
	
	
	
	if Input.is_action_pressed(A) and not Input.is_action_pressed(W) and not Input.is_action_pressed(S) and not heavyAttacking:
		attack.rotation_degrees = 180
		heavy_attack.flip_h = true
		attackArea.position.x = w.position.x
		attackArea.position.y = 0
		player_back.position.x = 10
		if attacking:
			# Attack dashes respect the attack speed range
			velocity.x = direction * attackSpeedRange if direction != 0 else locked_direction * attackSpeedRange
	elif Input.is_action_pressed(D) and not Input.is_action_pressed(W) and not Input.is_action_pressed(S) and not heavyAttacking:
		attack.rotation_degrees = 0
		heavy_attack.flip_h = false
		attackArea.position.x = e.position.x
		attackArea.position.y = 0
		player_back.position.x = -10
		if attacking:
			# Attack dashes respect the attack speed range
			velocity.x = direction * attackSpeedRange if direction != 0 else locked_direction * attackSpeedRange
	elif Input.is_action_pressed(W) and not heavyCharging and not heavyAttacking:
		attack.rotation_degrees = -90
		attackArea.position.x = 0
		attackArea.position.y = n.position.y
		if attacking and canDashAttackJump:
			# Attack dashes respect the attack speed range
			velocity.y = -1 * attackSpeedRange
			canDashAttackJump = false
	elif Input.is_action_pressed(S) and not heavyCharging and not heavyAttacking:
		attack.rotation_degrees = 90
		attackArea.position.x = 0
		attackArea.position.y = s.position.y
		if attacking and canDashAttackJump2:
			# Attack dashes respect the attack speed range
			velocity.y = -1 * (attackSpeedRange / Globals.upboostAttackDown)
			canDashAttackJump2 = false

		
		
	if Input.is_action_just_pressed(HeavyAttack) and heavyCanAttack and canAttack and heavyCharge > 0 and attackArea.position.y != n.position.y and attackArea.position.y != s.position.y:
		if attackArea.position.x == w.position.x:
			attackArea.attack_facing_direction = Vector2.LEFT
		elif attackArea.position.x == e.position.x:
			attackArea.attack_facing_direction = Vector2.RIGHT
		heavyCharge -= 1
		charge_orb.visible = true
		heavy_attack.visible = true
		animation.play("Heavy Attack")
		heavyCanAttack = false
		heavyAttacking = true
		Globals.attackType = 2
		canChangeDirection = false
		attack_pause.start()
		heavy_cooldown.start()
		orb_cooldown.start()
		
	if Input.is_action_just_pressed(Attack) and canAttack and not heavyAttacking:
		if attackArea.position.x == w.position.x:
			attackArea.attack_facing_direction = Vector2.LEFT
		elif attackArea.position.x == e.position.x:
			attackArea.attack_facing_direction = Vector2.RIGHT
		elif attackArea.position.y == n.position.y:
			attackArea.attack_facing_direction = Vector2.UP
		elif attackArea.position.y == s.position.y:
			attackArea.attack_facing_direction = Vector2.DOWN
			
		attack.visible = true
		attacking = true
		Globals.attackType = 1
		animation.play("Slash")
		canAttack = false
		attack_cooldown.start()
		attack_timer.start()
	
	
	 # Knockback
	if knockback_strength > 0:
		velocity = knockback_vector
		knockback_strength -= knockback_decay_rate * delta
		knockback_vector = knockback_vector.normalized() * knockback_strength
		if knockback_strength < 1.0:
			knockback_strength = 0.0
			knockback_vector = Vector2.ZERO
	
			
	# Move the character
	move_and_slide()
	

func collect_item(item_name: String, amount: int):
	print("Collected:", item_name, "x", amount)
	if item_name == "power up":
		heavyCharge = 999
		#(80, 62, 100, 255) # 60
		charge_orb.modulate = Color(0, 100, 255, 255)
		heavy_buff.start()
	elif item_name == "chance":
		var fiftyfifty = randi()%2
		if fiftyfifty == 0:
			chanceOption = 0
			onHit(Vector2(0,0), 0, 200)
			$Timers/ChanceTimer.start()
		elif fiftyfifty == 1:
			chanceOption = 1
			Globals.playerDamage = Globals.playerDamage * 2.5
			Globals.playerHeavyDamage = Globals.playerHeavyDamage * 2.5
			$Timers/ChanceTimer.start()


func onHit(direction: Vector2, strength: float, damage: int = 0) -> void:
	if not invincible:
		hp += damage  # Ensure hp is updated correctly
		var scaled_strength = strength * (1 + damage / 100.0)
		knockback_vector = direction.normalized() * scaled_strength
		knockback_strength = scaled_strength
		if hp >= 50 and hp <= 99:
			strength_knockback = HPM2
			hp_bar.tint_progress = Color(255/ 255.0, 255/ 255.0, 100/ 255.0)
			player_update_health.emit(Color(255/ 255.0, 255/ 255.0, 100/ 255.0))
		elif hp >= 100 and hp <= 149:
			strength_knockback = HPM3
			hp_bar.tint_progress = Color(255/ 255.0, 166/ 255.0, 9/ 255.0) 
			player_update_health.emit(Color(255/ 255.0, 166/ 255.0, 9/ 255.0))
		elif hp >= 150 and hp <= 199:
			strength_knockback = HPM4
			hp_bar.tint_progress = Color(255/ 255.0, 0, 0) 
			player_update_health.emit(Color(255/ 255.0, 0, 0))
		elif hp >= 200 and hp <= 249:
			strength_knockback = HPM5
			hp_bar.tint_progress = Color(150/ 255.0, 0, 0) 
			player_update_health.emit(Color(150/ 255.0, 0, 0))
		elif hp >= 250 and hp <= 299:
			strength_knockback = HPM6
			hp_bar.tint_progress = Color(94/ 255.0, 0, 0) 
			player_update_health.emit(Color(94/ 255.0, 0, 0))
		elif hp >= 300 and hp <= 449:
			strength_knockback = HPM7
			hp_bar.tint_progress = Color(47/ 255.0, 0, 0) 
			player_update_health.emit(Color(47/ 255.0, 0, 0))
		elif hp >= 450:
			hp_bar.tint_progress = Color(10/ 255.0, 10/ 255.0, 10/ 255.0) 
			player_update_health.emit(Color(10/ 255.0, 10/ 255.0, 10/ 255.0))
		print("Player:", player_id," HP:", hp, " Knockback:",strength_knockback)  # Debugging to ensure correct value
		
	if hp >= 500 and not is_dead:
		die()

func die() -> void:
	is_dead = true
	playerDied.emit()
	print("Player", player_id, "died")
	queue_free()  # Removes the player from the scene
	


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	attack.visible = false
	heavy_attack.visible = false
	


func _on_attack_cooldown_timeout() -> void:
	canAttack = true


func _on_dash_cooldown_timeout() -> void:
	canDash = true


func _on_dash_timer_timeout() -> void:
	dashing = false


func _on_attack_timer_timeout() -> void:
	attacking = false


func _on_heavy_cooldown_timeout() -> void:
	heavyCanAttack = true
	


func _on_attack_pause_timeout() -> void:
	heavyAttacking = false
	canChangeDirection = true


func _on_orb_cooldown_timeout() -> void:
	charge_orb.visible = false


func _on_heavy_buff_timeout() -> void:
	heavyCharge = 0
	charge_orb.modulate = Color(1,1,1,1)


func _on_chance_timer_timeout() -> void:
	if chanceOption == 0:
		chanceOption = null
		hp -= 200
	elif chanceOption == 1:
		chanceOption = null
		Globals.playerDamage = Globals.playerDamage / 2
		Globals.playerHeavyDamage = Globals.playerHeavyDamage / 2
