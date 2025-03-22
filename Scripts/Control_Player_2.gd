extends CharacterBody2D

#speed is applied, wlk_speed and run_speed alter speed
var speed : float
var friction : float
var wlk_speed = 50.0
var run_speed = 150.0

var crawl_speed = 35.0
var tuck_force = -200.0
var can_tuck = false
@onready var l_ray = $Left_Ray
@onready var r_ray = $Right_Ray

#jump_force is the jump height, jump_decel is how quick the player decelerates
const jump_force = -300.0
var jump_decel = 0.5
var can_coyote_jump = false

@onready var anim_tree : AnimationTree = $AnimationTree
@onready var prev_pos = position.x

func _physics_process(delta: float) -> void:
	
	# HANDLE MOVING
	var direction = Input.get_axis("Left", "Right")
	velocity.x = move_toward(velocity.x, direction * speed, speed * friction)
	if direction != 0:
		$Appearance.scale.x = -direction
		anim_tree["parameters/conditions/is_idle"] = false


	#AIRBORNE
	if !is_on_floor():
		anim_tree["parameters/conditions/is_running"] = false
		anim_tree["parameters/conditions/is_idle"] = false
		anim_tree["parameters/conditions/is_crawling"] = false
		anim_tree["parameters/conditions/is_crouching"] = false
		velocity += get_gravity() * delta
		
		#HANDLE FALLING
		if self.velocity.y > 0 and !Input.is_action_pressed("Down"):
			anim_tree["parameters/conditions/is_jumping"] = false
			anim_tree["parameters/conditions/is_falling"] = true
	
		#HANDLE TUCKING
		#if you're tucking...
		if Input.is_action_just_pressed("Down") and !velocity.y < -300:
			#...your collision is reduced and...
			$Body_Collision.scale.y = 0.5
			$Body_Collision.position.y = 8.5
			#...you get a little boost
			if can_tuck:
				velocity.y = tuck_force
				can_tuck = false
		elif Input.is_action_just_released("Down"):
			anim_tree["parameters/conditions/is_tucking"] = false
		if Input.is_action_pressed("Down"):
			anim_tree["parameters/conditions/is_tucking"] = true
			anim_tree["parameters/conditions/is_falling"] = false
			anim_tree["parameters/conditions/is_jumping"] = false

	#GROUNDED
	elif is_on_floor() or can_coyote_jump:
		can_tuck = true


		#HANDLE LANDING
		if anim_tree["parameters/conditions/is_falling"] == true or anim_tree["parameters/conditions/is_tucking"] == true:
			$"Timers/Landing Impact".start()
			anim_tree["parameters/conditions/landed"] = true
			anim_tree["parameters/conditions/is_idle"] = false

		anim_tree["parameters/conditions/is_falling"] = false
		anim_tree["parameters/conditions/is_tucking"] = false


		#HANDLE JUMP (Coyote Time)
		# If you're on the floor or kind of off on the floor...
		if Input.is_action_pressed("Up") and anim_tree["parameters/conditions/landed"] == false:
			anim_tree["parameters/conditions/is_idle"] = false
			anim_tree["parameters/conditions/is_walking"] = false
			anim_tree["parameters/conditions/is_jumping"] = true
			velocity.y = jump_force


		# HANDLE SPRINTING
		var current_pos = position.x
		if Input.is_action_pressed("Sprint") and !Input.is_action_pressed("Down") and direction != 0:
			if Input.is_action_pressed("Down"):
				speed = crawl_speed
				friction = 0.04
			else:
				speed = run_speed
				friction = 0.08
				anim_tree["parameters/conditions/is_running"] = true
				anim_tree["parameters/conditions/is_walking"] = false
				anim_tree["parameters/conditions/is_idle"] = false
				anim_tree["parameters/conditions/is_sliding"] = false
				
		#HANDLE WALKING
		elif direction != 0:
			anim_tree["parameters/conditions/is_walking"] = true
			anim_tree["parameters/conditions/is_idle"] = false
			anim_tree["parameters/conditions/is_running"] = false
			speed = wlk_speed
			friction = 0.2
		#IDLE
		if anim_tree["parameters/conditions/landed"] == false and current_pos == prev_pos:
			anim_tree["parameters/conditions/is_walking"] = false
			anim_tree["parameters/conditions/is_running"] = false
			anim_tree["parameters/conditions/is_idle"] = true
		prev_pos = current_pos


		#HANDLE CROUCHING
		#if you're not crouching...
		if !Input.is_action_pressed("Down") and (!l_ray.is_colliding() and !r_ray.is_colliding()):
			#your collision is normal
			$Body_Collision.position.y = 0
			$Body_Collision.scale.y = 1
			anim_tree["parameters/conditions/is_crouching"] = false
			anim_tree["parameters/conditions/is_crawling"] = false
		#if you're crouching...
		if Input.is_action_pressed("Down") or (l_ray.is_colliding() or r_ray.is_colliding()):
			#your collision is reduced and...
			$Body_Collision.scale.y = 0.5
			$Body_Collision.position.y = 8.5
			anim_tree["parameters/conditions/is_idle"] = false
			anim_tree["parameters/conditions/is_running"] = false
			anim_tree["parameters/conditions/is_walking"] = false
			
			if velocity.x != 0:
				#we're sliding
				if Input.is_action_pressed("Sprint") and (velocity.x > crawl_speed or velocity.x < -crawl_speed):
					anim_tree["parameters/conditions/is_sliding"] = true
					anim_tree["parameters/conditions/is_crawling"] = false
					anim_tree["parameters/conditions/is_crouching"] = false
				#we're crawling
				else:
					anim_tree["parameters/conditions/is_sliding"] = false
					anim_tree["parameters/conditions/is_crawling"] = true
					anim_tree["parameters/conditions/is_crouching"] = false
			else:
				anim_tree["parameters/conditions/is_sliding"] = false
				anim_tree["parameters/conditions/is_crawling"] = false
				anim_tree["parameters/conditions/is_crouching"] = true
			#speed is reduced and tuck-ability is reset
			speed = crawl_speed
			friction = 0.08


	#"move_and_slide" is what reports if you were on the floor...
	var was_on_floor = is_on_floor()
	move_and_slide()
	#...so we can put that in a variable, we can check afterwards to determine...
	#...if we were on the floor but are now off the floor
	if was_on_floor and !is_on_floor() and velocity.y >= 0:
		#we can then use that and a check to see if we're falling to start our timer
		can_coyote_jump = true
		$"Timers/Coyote Timer".start()
		#(timer and "can_coyote_time" is used above)

func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false

func _on_landing_impact_timeout() -> void:
	anim_tree["parameters/conditions/landed"] = false
