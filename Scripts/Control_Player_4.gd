extends CharacterBody2D

#MOVEMENT VARIABLES
var speed : float
var friction : float

var can_tuck = false
var landed : bool

var equipped_item : RigidBody2D
var can_attack : bool = true

var can_coyote_jump = false

@onready var prev_pos = position.x

func _ready() -> void:
	
	#Set Player Customization
	$Appearance/Hair.frame = CosmeticManager.hair_type
	$Appearance/Top_Clothing.visible = CosmeticManager.top_clothing
	$Appearance/Bottom_Clothing.visible = CosmeticManager.bottom_clothing
	$Appearance/Body.set_modulate(CosmeticManager.skin)

func _physics_process(delta: float) -> void:
	#HANDLE HEALTH
	$"Health Overshoot".value = $"Health Bar".value - $"Health Bar".max_value
	if $"Health Bar".value == $"Health Bar".max_value:
		$"Health Bar".visible = false
	elif $"Health Bar".value > $"Health Bar".max_value:
		$"Health Bar".visible = true
		if $"Timers/Overeat".is_stopped():
			$"Timers/Overeat".start()
	else:
		$"Health Bar".visible = true
	if $"Health Bar".value == 0:
		dead()

	# HANDLE MOVING
	var direction = Input.get_axis("Left", "Right")
	velocity.x = move_toward(velocity.x, direction * speed, speed * friction)
	if direction != 0:
		$Appearance.scale.x = -direction
		$"Hurt Box".get_child(0).position.x = 26 * direction

	#AIRBORNE
	if !is_on_floor():
		$AnimationTree["parameters/conditions/Grounded"] = false
		$AnimationTree["parameters/conditions/Airborne"] = true
		velocity += get_gravity() * delta
		landed = false

		#TUCKING
		if can_tuck and Input.is_action_just_pressed("Crouch"):
			velocity.y = -200
			can_tuck = false
		if Input.is_action_pressed("Crouch"):
			#...your collision is reduced and...
			$Body_Collision.scale.y = 0.5
			$Body_Collision.position.y = 8.5
			$AnimationTree["parameters/Airborne/blend_position"] = -0.5

		#RISING
		elif velocity.y < 0:
			$AnimationTree["parameters/Airborne/blend_position"] = 1
		
		#FALLING
		elif velocity.y > 0:
			$AnimationTree["parameters/Airborne/blend_position"] = 0.6

		move_and_slide()

	#GROUNDED
	else:
		can_tuck = true
		$AnimationTree["parameters/conditions/Grounded"] = true
		$AnimationTree["parameters/conditions/Airborne"] = false

		#HANDLE LANDING
		if !landed:
			if $"Timers/Landing Impact".is_stopped():
				$"Timers/Landing Impact".start()
			speed = 120
			friction = 0.08
			$AnimationTree["parameters/Grounded/blend_position"] = Vector2(0,-0.2)
		
		#DONE LANDING
		else:

			#CROUCH
			if Input.is_action_pressed("Crouch") or ($Left_Ray.is_colliding() or $Right_Ray.is_colliding()):
				#your collision is reduced and...
				$Body_Collision.scale.y = 0.5
				$Body_Collision.position.y = 8.5
				if velocity.x != 0:
					#SLIDING
					if (velocity.x > 35 or velocity.x < -35):
						friction = 0.01
						$"AnimationTree"["parameters/Grounded/blend_position"] = Vector2(1,-1)
						
					#CRAWLING
					else:
						$"AnimationTree"["parameters/Grounded/blend_position"] = Vector2(0.5,-1)
				#CROUCH IDLE
				else:
					$"AnimationTree"["parameters/Grounded/blend_position"] = Vector2(0,-1)
				#speed is reduced and tuck-ability is reset
				speed = 35
				friction = 0.08
			
			#JUMP
			elif Input.is_action_pressed("Up"):
				$AnimationTree["parameters/Airborne/blend_position"] = 1
				velocity.y = -300
			
			#ATTACKING
			elif Input.is_action_just_pressed("Attack"):
				if can_attack:
					for thing in $"Hurt Box".get_overlapping_bodies():
						if thing.get_class() == "RigidBody2D":
							thing.apply_central_impulse(Vector2(50, -1000))
						if thing.get_class() == "CharacterBody2D":
							thing.take_damage(5, Vector2(-500 * $Appearance.scale.x, -300), true)
						$"Timers/Attack Cooldown".start()
						can_attack = false

			#RUNNING
			elif Input.get_axis("Left", "Right"):
				speed = 150
				friction = 0.08
				$"AnimationTree"["parameters/Grounded/blend_position"] = Vector2(1,0)

			#IDLE
			else:
				$"AnimationTree"["parameters/Grounded/blend_position"] = Vector2(0,0)

		move_and_slide()

func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false

func _on_landing_impact_timeout() -> void:
	landed = true

func dead():
	get_tree().change_scene_to_file("res://Scenes/Death_Screen.tscn")

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_timer_timeout() -> void:
	if $"Health Bar".value <= $"Health Bar".max_value:
		$"Timers/Overeat".stop()
	$"Health Bar".value -= 1
