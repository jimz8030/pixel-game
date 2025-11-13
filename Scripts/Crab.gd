extends CharacterBody2D

var player_opinion = 0
var speed : int
var safe : bool = true

#LEFT or RIGHT
var one_o_two : int
#CLIMBING
var was_climbing : bool


#Code that needs to be ran every frame
func _physics_process(delta: float) -> void:
	if !is_on_floor() and !is_on_wall():
		$AnimationTree["parameters/Move/blend_position"] = -1.0
		velocity += get_gravity() * delta
		#Give a boost so we don't get stuck on corners
		if was_climbing:
			if $Appearance.rotation_degrees == -90.0:
				velocity = Vector2(20,-20)
			else:
				velocity = Vector2(-20,-20)
			velocity.y -= 100
			was_climbing = false
	elif is_on_floor():
		$Appearance.rotation_degrees = 0.0
		$Appearance.position = Vector2(0,-8.95)
	if is_on_ceiling():
		if $Wall_Feel_L.is_colliding():
			one_o_two = 2
		else:
			velocity.x += 80
			one_o_two = 1

	move_and_slide()
	
	#CLIMB
	if $Wall_Feel_L.is_colliding() or $Wall_Feel_R.is_colliding() and !is_on_ceiling():
		#goes up when reaching a wall
		if $Wall_Feel_L.is_colliding() and one_o_two == 1:
			velocity.y = -speed
			$Appearance.rotation_degrees = -90.0
			$Appearance.position = Vector2(-5,-4)
		elif $Wall_Feel_R.is_colliding() and one_o_two == 2:
			velocity.y = -speed
			$Appearance.rotation_degrees = 90.0
			$Appearance.position = Vector2(5,-4)
		#falls when hitting a cieling
		else:
			velocity += get_gravity() * delta
		was_climbing = true

#Performs actions every 0.5 seconds
func _on_action_timer_timeout() -> void:

	#OUT OF COMBAT: Roam
	if safe:
		#Set UI Color
		if $"Stats/Safe Box".color != Color(0.76, 0.76, 0.79, 1):
			$"Stats/Safe Box".color = Color(0.76, 0.76, 0.79, 1)

		#Make a random number to decide whether to go left or right
		if one_o_two == 0:
			one_o_two = randi_range(1,2)
		#chose to go right
		if one_o_two == 1:
			wander_time([1, 1, 1, 0], [7.0, 10.0, 15.0])
		#chose to go left
		if one_o_two == 2:
			wander_time([-1,-1,-1, 0], [7.0, 10.0, 15.0])
		
		if $"Stats/Health Bar".value < $"Stats/Health Bar".max_value:
			#speed is halved while healing
			speed = 18
			#start healing
			if $Action_Timer/Heal.is_stopped():
				$Action_Timer/Heal.start()
		else:
			speed = 40
			$Action_Timer/Heal.stop()

	#COMBAT
	if !safe:
		pass

#Choosing Direction and Moving
func wander_time(directions : Array, travel_times : Array) -> void:
	#Numbers stored in the arrays are used to determine where to go and how long to travel for
	var direction
	var travel_time
	#Stopping occasionally along the way
	if travel_times.size() > 0:
		directions.shuffle()
		travel_times.shuffle()
		direction = directions.front()
		travel_time = travel_times.front()
		$Action_Timer/Wander.start(travel_time)
	#Directly to objective
	else:
		direction = directions.front()
		$Action_Timer/Wander.start()
		
	#Apply movement conditions
	if direction != 0:
		$Appearance.scale.x = -direction
		$"Consume Area".scale.x = -direction
		#HANDLE ANIMATION
		$AnimationTree["parameters/Move/blend_position"] = 1.0
	else:
		$AnimationTree["parameters/Move/blend_position"] = 0.0
	velocity.x = speed * direction

#EAT FOOD
func _on_consume_area_body_entered(body: Node2D) -> void:
	if body != $"../PlayerBody":
		if body.eat_heal_amount > 0 and $"Stats/Health Bar".value < $"Stats/Health Bar".max_value - 2:
			$"Stats/Health Bar".value += body.eat_heal_amount
			body.queue_free()
			wander_time([0], [1])

#Crab is healing
func _on_heal() -> void:
	$"Stats/Health Bar".value += 0.1

func take_damage(dmg_amount : int, knockback_amount : Vector2, player_attacking : bool):
	velocity += knockback_amount
	move_and_slide()
	$"Stats/Health Bar".value -= dmg_amount
	if player_attacking:
		player_opinion -= dmg_amount
	if $"Stats/Health Bar".value == 0:
		var item_in_file : PackedScene = preload("res://Inventory/Inventory_Items/Meat.tscn")
		var item_to_drop : RigidBody2D = item_in_file.instantiate()
		$"..".add_child(item_to_drop)
		item_to_drop.position = self.position
		item_to_drop.apply_impulse(Vector2(knockback_amount.x, knockback_amount.y))
		self.queue_free()
