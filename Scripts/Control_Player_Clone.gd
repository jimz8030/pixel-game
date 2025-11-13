extends CharacterBody2D

#MOVEMENT VARIABLES
var speed : float
var friction : float

var can_control = false

func _physics_process(delta: float) -> void:

	if can_control:
		# HANDLE MOVING
		var direction = Input.get_axis("Left", "Right")
		velocity.x = move_toward(velocity.x, direction * speed, speed * friction)
		if direction != 0:
			$Appearance.scale.x = -direction

		#AIRBORNE
		if !is_on_floor():
			velocity += get_gravity() * delta

			move_and_slide()

		#GROUNDED
		else:

			#CRAWLING
			if Input.get_axis("Left", "Right"):
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
