extends CharacterBody2D

#MOVEMENT VARIABLES
var speed : float
var friction : float

var can_tuck = false
var landed : bool

var equipped_item : RigidBody2D

var can_attack : bool = true
var in_attack_state : bool
var attack_queue : int
var attack_count : int = 1
var damage_signal : bool


var can_coyote_jump = false

@onready var prev_pos = position.x

func _physics_process(delta: float) -> void:

	# HANDLE MOVING
	var direction = Input.get_axis("Left", "Right")
	velocity.x = move_toward(velocity.x, direction * speed, speed * friction)
	if direction != 0:
		$Appearance.scale.x = -direction

	#AIRBORNE
	if !is_on_floor():
		$AnimationTree.get("parameters/playback").travel("Airborne")
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
			$Body_Collision.scale.y = 1
			$Body_Collision.position.y = 1.5
		
		#FALLING
		elif velocity.y > 0:
			$AnimationTree.get("parameters/playback").travel("3c- Female Fall")
			$Body_Collision.scale.y = 1
			$Body_Collision.position.y = 1.5

		move_and_slide()

	#GROUNDED
	else:
		can_tuck = true
		if !in_attack_state:
			$AnimationTree.get("parameters/playback").travel("Grounded")
		else:
			velocity.x /= 2

		#HANDLE LANDING
		if !landed:
			if $"Timers/Landing Impact".is_stopped():
				$"Timers/Landing Impact".start()
			speed = 0
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
						$AnimationTree.get("parameters/playback").travel("2d- Female Slide")
						
					#CRAWLING
					else:
						$"AnimationTree"["parameters/Grounded/blend_position"] = Vector2(0.5,-1)
				#CROUCH IDLE
				else:
					$AnimationTree.get("parameters/playback").travel("2a- Female Crouch")
				#speed is reduced and tuck-ability is reset
				speed = 35
				friction = 0.08
			
			#JUMP
			elif Input.is_action_pressed("Up"):
				$AnimationTree["parameters/Airborne/blend_position"] = 1
				velocity.y = -300
				$Body_Collision.scale.y = 1
				$Body_Collision.position.y = 1.5

			#RUNNING
			elif Input.get_axis("Left", "Right"):
				speed = 50
				friction = 0.08
				$"AnimationTree"["parameters/Grounded/blend_position"] = Vector2(1,0)
				$Body_Collision.scale.y = 1
				$Body_Collision.position.y = 1.5

			#IDLE
			else:
				$"AnimationTree"["parameters/Grounded/blend_position"] = Vector2(0,0)
				$Body_Collision.scale.y = 1
				$Body_Collision.position.y = 1.5

		move_and_slide()

func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false

func _on_landing_impact_timeout() -> void:
	landed = true

func _on_timer_timeout() -> void:
	if $"Health Bar".value <= $"Health Bar".max_value:
		$"Timers/Overeat".stop()
	$"Health Bar".value -= 1
