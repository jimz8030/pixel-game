extends CharacterBody2D

var player_opinion = 0

@export var animal_name : String
@export var taming_level : int

var speed : int = 120

var safe : bool = true
var stat_focus : String

#LINES OF SIGHT
var line_to_player
var line_to_base
var bookmark_line

#NAVIGATION
var bookmarks : Array

#LEFT or RIGHT
var one_o_two : int
#TURN AROUND AT WALL
var jumped = false
#DETECT JUMPPADS
var jumppad : Area2D
#Store nearby Ottle to sleep next to later
var recent_friend : CharacterBody2D
#Signal when sleeping
var is_sleeping : bool

#START OF SCENE
func _ready() -> void:
	$"Stats/Drowsy Bar".value = randi_range(2,15)
	$"Stats/Hunger Bar".value = randi_range(5,15)

#Code that needs to be ran every frame
func _physics_process(delta: float) -> void:
	if !is_on_floor():
		$AnimationTree["parameters/conditions/is_running"] = false
		$AnimationTree["parameters/conditions/is_standing"] = false
		$AnimationTree["parameters/conditions/is_idle"] = false
		$AnimationTree["parameters/conditions/is_walking"] = false
		#REPLACE WITH FALLING ANIMATION
		$AnimationTree["parameters/conditions/is_idle"] = true
		velocity += get_gravity() * delta
		
		#turn around if can't jump over a wall
		if jumped and velocity.x == 0:
			if one_o_two == 1:
				one_o_two = 2
			else:
				one_o_two = 1
			jumped = false
	move_and_slide()
	
	#JUMP
	if $Tether_Line/Jump_Cast_Left.is_colliding() and is_on_floor() and velocity.x < 0:
		velocity.y -= 300
		$AnimationTree["parameters/conditions/is_running"] = false
		$AnimationTree["parameters/conditions/is_standing"] = false
		$AnimationTree["parameters/conditions/is_idle"] = false
		$AnimationTree["parameters/conditions/is_walking"] = false
		#REPLACE WITH JUMPING ANIMATION
		$AnimationTree["parameters/conditions/is_idle"] = true
		#Used to determine if ottle should turn around (SEE ABOVE)
		jumped = true
	elif $Tether_Line/Jump_Cast_Right.is_colliding() and is_on_floor() and velocity.x > 0:
		velocity.y -= 300
		$AnimationTree["parameters/conditions/is_running"] = false
		$AnimationTree["parameters/conditions/is_standing"] = false
		$AnimationTree["parameters/conditions/is_idle"] = false
		$AnimationTree["parameters/conditions/is_walking"] = false
		#REPLACE WITH JUMPING ANIMATION
		$AnimationTree["parameters/conditions/is_idle"] = true
		#Used to determine if ottle should turn around (SEE ABOVE)
		jumped = true

#Performs actions every 0.5 seconds
func _on_action_timer_timeout() -> void:
	#Draw line to player for detection
	if line_to_player != null:
		line_to_player.target_position = $"../PlayerBody".position - self.position
	if self.position.x - $"../PlayerBody".position.x > 400 or \
	self.position.x - $"../PlayerBody".position.x < -400 or \
	self.position.y - $"../PlayerBody".position.y < -200 or \
	self.position.y - $"../PlayerBody".position.y > 200:
		$Stats.visible = false

	#OUT OF COMBAT: Keep stats up
	if safe:
		#Set UI Color
		if $"Stats/Safe Box".color != Color(0.76, 0.76, 0.79, 1):
			$"Stats/Safe Box".color = Color(0.76, 0.76, 0.79, 1)

		#Hunger and Drowsy decrease over time
		$"Stats/Drowsy Bar".value -= 0.02
		$"Stats/Hunger Bar".value -= 0.03

		#Approach your sleepy buddy
		if recent_friend != null:
			if recent_friend.stat_focus == "Drowsy":
				#Found sleepy buddy
				if recent_friend.position.x > self.position.x - 50 and \
					recent_friend.position.x < self.position.x + 50 and \
					recent_friend.position.y > self.position.y - 50 and \
					recent_friend.position.y < self.position.y + 50:
						is_sleeping = true
						$Action_Timer/Sleep.start()
						velocity.x = 0
				#friend is to the right
				elif recent_friend.position.x > self.position.x - 50:
					wander_time([1],[])
				#friend is to the left
				elif recent_friend.position.x < self.position.x + 50:
					wander_time([-1],[])
				#Use jumppad when friend is up
				if jumppad != null and recent_friend.position.y < self.position.y + 20:
					velocity.y -= jumppad.jump_boost

		#SET STAT FOCUS
		var hunger_emphasis = pow(1.5, 0.3 * ($"Stats/Hunger Bar".max_value - $"Stats/Hunger Bar".value)) - 1
		var health_emphasis = pow(1.3, 0.5 * ($"Stats/Health Bar".max_value - $"Stats/Health Bar".value)) - 1
		var drowsy_emphasis = (($"Stats/Drowsy Bar".max_value - $"Stats/Drowsy Bar".value) / 4)
		var top_contender = max(hunger_emphasis, health_emphasis, drowsy_emphasis)
		#Gotta stop all the movement when a friend is napping
		if recent_friend == null or !recent_friend.is_sleeping:
			if hunger_emphasis < 1.8 and health_emphasis < 0.3 and drowsy_emphasis < 2.3:
				stat_focus = "None"
			elif top_contender == hunger_emphasis:
				stat_focus = "Hunger"
			elif top_contender == health_emphasis:
				stat_focus = "Health"
			elif top_contender == drowsy_emphasis:
				stat_focus = "Drowsy"
		#Focus on your buddy when they're sleeping
		elif recent_friend.is_sleeping:
			stat_focus = "Friend"

		#RECOVER HUNGER
		if stat_focus == "Hunger":
			
			#REMEMBER MOST RECENT FOOD
			var closest_food : RigidBody2D
			for item in bookmarks:
				if item != null:
					if item.get_class() == "RigidBody2D":
						closest_food = item

			#DRAW LINE TO FOOD
			if closest_food != null:
				$Tether_Line/Food_Line.target_position = closest_food.position - self.position
			#Looks for food if none are remembered
			else:
				#Make a random number to decode between left and right
				if one_o_two == 0:
					one_o_two = randi_range(1,2)
				#chose to go right
				if one_o_two == 1:
					wander_time([1], [0])
				#chose to go left
				if one_o_two == 2:
					wander_time([-1], [0])

			if $Tether_Line/Food_Line.is_colliding():
				if $Tether_Line/Food_Line.get_collider() == closest_food:
					#FOOD IN SIGHT
					if $Tether_Line/Food_Line.target_position.x > 0:
						wander_time([1], [])
					elif $Tether_Line/Food_Line.target_position.x < 0:
						wander_time([-1], [])
				#keeps moving until food is in direct sight
				elif $Tether_Line/Food_Line.get_collider().get_class() == "StaticBody2D":
					#choose left or right
					if one_o_two == 0:
						one_o_two = randi_range(1,2)
					#chose to go right
					if one_o_two == 1:
						wander_time([1], [0])
					#chose to go left
					if one_o_two == 2:
						wander_time([-1], [0])
		if stat_focus!= "Hunger":
			$Tether_Line/Food_Line.target_position = Vector2(0,5)

		#RECOVER SLEEP (DROWSY)
		if stat_focus == "Drowsy":
			if $Action_Timer/Find_Friend.is_stopped():
				$Action_Timer/Find_Friend.start()
			#Ottle is nearby
			if recent_friend != null:
				#Start sleeping when next to a friend (have to check x and y positions)
				if recent_friend.position.x > self.position.x - 50 and \
				recent_friend.position.x < self.position.x + 50 and \
				recent_friend.position.y > self.position.y - 50 and \
				recent_friend.position.y < self.position.y + 50:
					is_sleeping = true
					$Action_Timer/Sleep.start()
					$Action_Timer/Sleep.wait_time = 10.0
					velocity.x = 0
				#friend is to the right
				elif recent_friend.position.x > self.position.x - 50:
					wander_time([1],[])
				#friend is to the left
				elif recent_friend.position.x < self.position.x + 50:
					wander_time([-1],[])
				#Use jumppad when friend is up
				if jumppad != null and recent_friend.position.y < self.position.y + 20:
					velocity.y -= jumppad.jump_boost
					jumppad == null
					
			#Can't find Ottle, so sleep slowly
			else:
				is_sleeping = true
				velocity.x = 0
				$Action_Timer/Sleep.start()
				$Action_Timer/Sleep.wait_time = 20.0

		#RECOVER HEALTH
		if stat_focus == "Health":
			#speed is halved while healing
			speed = 18
			#start healing
			if $Action_Timer/Heal.is_stopped():
				$Action_Timer/Heal.start()
			
			#Make a random number to decide whether to go left or right
			if one_o_two == 0:
				one_o_two = randi_range(1,2)
			#chose to go right
			if one_o_two == 1:
				wander_time([1,0], [])
			#chose to go left
			if one_o_two == 2:
				wander_time([-1,0], [])
		if stat_focus != "Health":
			#reset speed
			speed = 120
			#stop healing
			$Action_Timer/Heal.stop()

		#NO STATS NEED ATTENTI0N
		if stat_focus == "None":
			#Make a random number to decide whether to go left or right
			if one_o_two == 0:
				one_o_two = randi_range(1,2)
			#chose to go right
			if one_o_two == 1:
				wander_time([1, 1, 1, 1, 0, -1], [3.0, 4.0, 7.5])
			#chose to go left
			if one_o_two == 2:
				wander_time([-1,-1,-1, -1, 0, -1], [3.0, 4.0, 7.5])
			#Use Jumppads sometimes
			if jumppad != null:
				var jump_maybe = randi_range(0,1)
				if jump_maybe == 1:
					velocity.y -= jumppad.jump_boost
				jumppad = null
			#Ottle wall stuck fix
			if velocity.x == 0 and ($Tether_Line/Jump_Cast_Left.is_colliding() or $Tether_Line/Jump_Cast_Right.is_colliding()):
				if one_o_two == 2:
					one_o_two = 1
				else:
					one_o_two = 1
		if stat_focus != "None":
			$Action_Timer/Wander.stop()

	#COMBAT
	if !safe:
		pass

#BOOKMARK FOOD
#MARK OTTLES
#LINE TO PLAYER
func _on_sight_area_entered(body: Node2D) -> void:
	#Draw line to player when nearby
	if body.name == "PlayerBody":
		line_to_player = RayCast2D.new()
		line_to_player.collision_mask = 1 | 2
		self.add_child(line_to_player)
	#bookmark food
	elif body.get_class() == "RigidBody2D":
		if body.eat_heal_amount > 0:
			#Previous food is removed
			for item in bookmarks:
				if item != null:
					if item.get_class() == "Rigidbody2D":
						bookmarks.erase(item)
						break
			#New food bookmark is stored
			bookmarks.append(body)
			if bookmarks.size() > 2:
				bookmarks.remove_at(0)
	#Checks for Ottle (needs to get the first 5 letters of name because Ottles are numbered in scene
	#such as Ottle, Ottle2, Ottle3, etc.)
	elif str(body.name).substr(0,5) == "Ottle":
		#Stores location of fellow Ottle
		recent_friend = body
func _on_sight_area_exited(body: Node2D) -> void:
	if body.name == "PlayerBody":
		line_to_player.queue_free()

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
		$AnimationTree["parameters/conditions/is_standing"] = false
		$AnimationTree["parameters/conditions/is_idle"] = false
		if speed == 120:
			$AnimationTree["parameters/conditions/is_running"] = true
			$AnimationTree["parameters/conditions/is_walking"] = false
		else:
			$AnimationTree["parameters/conditions/is_running"] = false
			$AnimationTree["parameters/conditions/is_walking"] = true
	else:
		$AnimationTree["parameters/conditions/is_running"] = false
		$AnimationTree["parameters/conditions/is_standing"] = false
		$AnimationTree["parameters/conditions/is_walking"] = false
		$AnimationTree["parameters/conditions/is_idle"] = true
	velocity.x = speed * direction

#EAT FOOD
func _on_consume_area_body_entered(body: Node2D) -> void:
	if body != $"../PlayerBody":
		if body.eat_heal_amount > 0 and $"Stats/Hunger Bar".value < 12:
			$"Stats/Hunger Bar".value += body.eat_heal_amount * 1.5
			if body.get_child(0).node_b == $"../PlayerBody/ItemFrame/Pointer".get_path():
				Global_Variables.taming_strength += body.eat_heal_amount / 3
			body.queue_free()
			wander_time([0], [1])
#DETECT JUMPPAD
func _on_consume_area_area_entered(area: Area2D) -> void:
	jumppad = area

#Ottle woke up from a nap
func _on_wake_up() -> void:
	is_sleeping = false
	$"Stats/Drowsy Bar".value += $"Stats/Drowsy Bar".max_value
#Ottle sleeps alone if they can't find their buddy in time
func _on_find_friend_timeout() -> void:
	is_sleeping = true
	$Action_Timer/Sleep.start()

#Ottle is healing
func _on_heal() -> void:
	$"Stats/Health Bar".value += 1
	$"Stats/Hunger Bar".value -= 1
	$"Stats/Drowsy Bar".value -= 0.5

func take_damage(dmg_amount : int, knockback_amount : Vector2, player_attacking : bool):
	velocity += knockback_amount
	move_and_slide()
	$"Stats/Health Bar".value -= dmg_amount
	if player_attacking:
		player_opinion -= dmg_amount
	if $"Stats/Health Bar".value == 0:
		var item_in_file : PackedScene = preload("res://Inventory_Items/Meat.tscn")
		var item_to_drop : RigidBody2D = item_in_file.instantiate()
		$"..".add_child(item_to_drop)
		item_to_drop.position = self.position
		item_to_drop.apply_impulse(Vector2(knockback_amount.x / 4, knockback_amount.y / 2))
		Global_Variables.food_chain_xp += 15
		Global_Variables.ottle_killed += 1
		Global_Variables.taming_strength -= 1
		self.queue_free()
