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

func _ready() -> void:
	#Set Player Customization
	$Appearance/Hair.frame = Global_Variables.hair_type
	if Global_Variables.top_clothing.is_empty():
		$"Appearance/Top_Clothing".texture = load("res://Sprites/Player_Sprites/Clothing/T0_Pack.png")
	else:
		$"Appearance/Top_Clothing".texture = load(Global_Variables.top_clothing[Global_Variables.selected_top].load_path)
	$Appearance/Bottom_Clothing.visible = Global_Variables.bottom_clothing
	$Appearance/Body.set_modulate(Global_Variables.skin)

func _physics_process(delta: float) -> void:
	$"Taming Bar".value = Global_Variables.taming_strength
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
		$AnimationTree.get("parameters/playback").travel("Airborne")
		velocity += get_gravity() * delta
		landed = false

		#TUCKING
		if can_tuck and Input.is_action_just_pressed("Crouch") and velocity.y > -200:
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
			$AnimationTree.get("parameters/playback").travel("3c- Female Fall")

		move_and_slide()

	#GROUNDED
	else:
		can_tuck = true
		if !in_attack_state:
			$AnimationTree.get("parameters/playback").travel("Grounded")
		else:
			pass
			#velocity.x /= 2

		#HANDLE LANDING
		if !landed:
			if $"Timers/Landing Impact".is_stopped():
				$"Timers/Landing Impact".start()
			speed = 120
			friction = 0.08
			$AnimationTree["parameters/Grounded/blend_position"] = Vector2(0,-0.2)

		#ATTACKING
		elif Input.is_action_just_pressed("Attack") and can_attack:
			damage_signal = true
			attack_queue += 1
			if attack_queue > 3:
				attack_queue = 3
			if attack_count == 3:
				$"Timers/Attack Cooldown".wait_time = 0.6
			elif attack_count == 4:
				attack_count = 3
			else:
				$"Timers/Attack Cooldown".wait_time = 0.2
			$"Timers/Attack Cooldown".start()
			$"Timers/Attack Cooldown Pt2".start()

		elif attack_queue > 0:
			in_attack_state = true
			$AnimationTree.get("parameters/playback").travel("Attack " + str(attack_count))

		#DONE LANDING and NOT ATTACKING
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
				$Body_Collision.position.y = 1

			#RUNNING
			elif Input.get_axis("Left", "Right"):
				speed = 150
				friction = 0.08
				$"AnimationTree"["parameters/Grounded/blend_position"] = Vector2(1,0)
				$Body_Collision.scale.y = 1
				$Body_Collision.position.y = 1

			#IDLE
			else:
				$"AnimationTree"["parameters/Grounded/blend_position"] = Vector2(0,0)
				$Body_Collision.scale.y = 1
				$Body_Collision.position.y = 1

		move_and_slide()

func _on_coyote_timer_timeout() -> void:
	can_coyote_jump = false

func _on_landing_impact_timeout() -> void:
	landed = true

func dead():
	get_tree().change_scene_to_file("res://Scenes/Death_Screen.tscn")

func _on_attack_cooldown_timeout() -> void:
	attack_count += 1
	can_attack = true
	attack_queue -= 1
	$"Timers/Attack Cooldown Pt2".start()
func _on_attack_cooldown_pt_2_timeout() -> void:
	attack_count = 1
	in_attack_state = false
	attack_queue = 0

func deal_damage():
	if damage_signal:
		for thing in $"Hurt Box".get_overlapping_bodies():
			if thing.get_class() == "RigidBody2D":
				thing.apply_central_impulse(Vector2(0, -1000))
				if thing.name.erase(4,5) == "Crat":
					thing.break_open()
			if thing.get_class() == "CharacterBody2D":
				thing.take_damage(5, Vector2(-100 * $Appearance.scale.x, -200), true)
		damage_signal = false

func _on_timer_timeout() -> void:
	if $"Health Bar".value <= $"Health Bar".max_value:
		$"Timers/Overeat".stop()
	$"Health Bar".value -= 1
