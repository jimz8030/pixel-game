extends CharacterBody2D

var kill_count : int = 3

@export var health_total : int
var current_health : int

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

var equipped_item : RigidBody2D
var can_attack : bool = true

#jump_force is the jump height, jump_decel is how quick the player decelerates
const jump_force = -300.0
var jump_decel = 0.5
var can_coyote_jump = false

@onready var anim_tree : AnimationTree = $AnimationTree
@onready var prev_pos = position.x

func _ready() -> void:
	current_health = health_total
	$"Health Bar".max_value = health_total
	$"Health Overshoot".value = 0

func _physics_process(delta: float) -> void:

	#HANDLE HEALTH
	$"Health Bar".value = current_health
	$"Health Overshoot".value = current_health - health_total
	if current_health == health_total:
		$"Health Bar".visible = false
	elif current_health > health_total:
		$"Health Bar".visible = true
		if $"Timers/Overeat".is_stopped():
			$"Timers/Overeat".start()
	else:
		$"Health Bar".visible = true
	if current_health <= 0:
		dead()

	# HANDLE MOVING
	var direction = Input.get_axis("Left", "Right")
	velocity.x = move_toward(velocity.x, direction * speed, speed * friction)
	if direction != 0:
		$Appearance.scale.x = -direction
		$"Hurt Box".get_child(0).position.x = 26 * direction
		anim_tree["parameters/conditions/is_idle"] = false

	#HANDLE ATTACKING
	if equipped_item != null:
		$"../CanvasLayer/Kill_Instruction".visible = true
	if Input.is_action_just_pressed("Interact"):
		if equipped_item != null:
			$"Timers/Attack Cooldown".wait_time = equipped_item.attack_cooldown
			if can_attack:
				for thing in $"Hurt Box".get_overlapping_bodies():
					if thing.get_class() == "RigidBody2D":
						thing.apply_central_impulse(Vector2(50, -1000))
					if thing.get_class() == "CharacterBody2D":
						thing.take_damage(equipped_item.attack_damage,
						Vector2(equipped_item.attack_knockback * $Appearance.scale.x, -300),
						true)
						#thing.velocity += Vector2((-200 * $Appearance.scale.x), -300)
						#thing.move_and_slide()
						#thing.current_health -= equipped_item.attack_damage
					$"Timers/Attack Cooldown".start()
					can_attack = false

	#AIRBORNE
	if !is_on_floor():
		anim_tree["parameters/conditions/is_running"] = false
		anim_tree["parameters/conditions/is_idle"] = false
		anim_tree["parameters/conditions/is_crawling"] = false
		anim_tree["parameters/conditions/is_crouching"] = false
		anim_tree["parameters/conditions/is_sliding"] = false
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
	elif is_on_floor():
		can_tuck = true

		#HANDLE LANDING
		if anim_tree["parameters/conditions/is_falling"] == true or anim_tree["parameters/conditions/is_tucking"] == true:
			$"Timers/Landing Impact".start()
			anim_tree["parameters/conditions/landed"] = true
			anim_tree["parameters/conditions/is_idle"] = false

		anim_tree["parameters/conditions/is_falling"] = false
		anim_tree["parameters/conditions/is_tucking"] = false

		#HANDLE JUMP
		# If you're on the floor or kind of off on the floor...
		if Input.is_action_pressed("Up") and anim_tree["parameters/conditions/landed"] == false:
			velocity.y = jump_force
			anim_tree["parameters/conditions/is_idle"] = false
			anim_tree["parameters/conditions/is_walking"] = false
			anim_tree["parameters/conditions/is_jumping"] = true


		# HANDLE SPRINTING
		var current_pos = position.x
		#Player cannot sprint while carrying items
		var carrying_item : bool
		if $ItemFrame.selected_item != null and Input.is_action_pressed("Left_Click"):
			carrying_item = true
		else:
			carrying_item = false
		
		if !Input.is_action_pressed("Down") and direction != 0 and !carrying_item:
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
				if (velocity.x > crawl_speed or velocity.x < -crawl_speed):
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
	if can_coyote_jump and Input.is_action_just_pressed("Up"):
		velocity.y = jump_force
		anim_tree["parameters/conditions/is_idle"] = false
		anim_tree["parameters/conditions/is_walking"] = false
		anim_tree["parameters/conditions/is_falling"] = false
		anim_tree["parameters/conditions/is_jumping"] = true

func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false

func _on_landing_impact_timeout() -> void:
	anim_tree["parameters/conditions/landed"] = false

func dead():
	get_tree().change_scene_to_file("res://Scenes/Death_Screen.tscn")

func _on_attack_cooldown_timeout() -> void:
	can_attack = true

func _on_timer_timeout() -> void:
	if current_health <= health_total:
		$"Timers/Overeat".stop()
	current_health -= 1

func win_count():
	kill_count -= 1
	$"../CanvasLayer/kill_counter".text = str(kill_count)
	if kill_count == 0:
		get_tree().change_scene_to_file("res://Scenes/Win_Screen.tscn")
