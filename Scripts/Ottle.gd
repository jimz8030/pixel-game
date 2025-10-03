extends CharacterBody2D

@export var speed : int

var safe : bool
var stat_focus : String

#LINES OF SIGHT
var line_to_player
var line_to_base
var bookmark_line

var bookmarks : Array

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

#
func _on_action_timer_timeout() -> void:
	#Player Detection
	if line_to_player != null:
		line_to_player.target_position = $"../PlayerBody".position - self.position
	
	#Replace with a check if they got hit or spot the player
	safe = true
	#ROAMING
	if safe:
		if $"Stats/Safe Box".color != Color(0.76, 0.76, 0.79, 1):
			$"Stats/Safe Box".color

		#Hunger and Drowsy decrease over time
		#$"Stats/Drowsy Bar".value -= 0.02
		#$"Stats/Hunger Bar".value -= 0.03
		#SET STAT FOCUS
		var hunger_emphasis = pow(1.5, 0.3 * ($"Stats/Hunger Bar".max_value - $"Stats/Hunger Bar".value)) - 1
		var health_emphasis = pow(1.3, 0.5 * ($"Stats/Health Bar".max_value - $"Stats/Health Bar".value)) - 1
		var drowsy_emphasis = (($"Stats/Drowsy Bar".max_value - $"Stats/Drowsy Bar".value) / 4)
		var top_contender = max(hunger_emphasis, health_emphasis, drowsy_emphasis)
		if hunger_emphasis < 2 and health_emphasis < 0.3 and drowsy_emphasis < 2.3:
			stat_focus = "None"
		elif top_contender == hunger_emphasis:
			stat_focus = "Hunger"
		elif top_contender == health_emphasis:
			stat_focus = "Health"
		elif top_contender == drowsy_emphasis:
			stat_focus = "Drowsy"
			
		print ("Focus: " + stat_focus)
		
		#RECOVER HUNGERY
		if stat_focus == "Hunger":
			pass
		#RECOVER DROWSY
		if stat_focus == "Drowsy":
			pass
		#RECOVER HEALTH
		if stat_focus == "Health":
			pass
		#WANDERING
		if stat_focus == "None":
			var facing : int
			self.velocity.x = speed * facing
			var available_paths : Array = [1,1,1,0,-1]
			var one_o_zero = randi_range(0,1)
			#chose to go left
			if one_o_zero == 0:
				wander_time(available_paths, [3.0, 4.0, 5.5, 1.0, 1.0])
			#chose to go right
			if one_o_zero == 1:
				for number in available_paths:
					number *= -1
				wander_time(available_paths, [3.0, 4.0, 5.5])
			#JUMP
			if $Jump_Cast_Right.is_colliding() and is_on_floor():
				velocity.y -= 300
				if !made_the_jump():
					for number in available_paths:
						number *= -1
			elif $Jump_Cast_Right.is_colliding() and is_on_floor():
				velocity.y -= 300
				made_the_jump()

	#COMBAT
	if !safe:
		stat_focus == "None"

#BOOKMARK FOOD
#BOOKMARK JUMPPADS
#LINE TO PLAYER
func _on_sight_area_entered(body: Node2D) -> void:
	#Draw line to player when nearby
	if body.name == "PlayerBody":
		line_to_player = RayCast2D.new()
		line_to_player.collision_mask = 1 | 2
		self.add_child(line_to_player)
	#bookmark food
	elif body.get_class() == "RigidBody2D":
		#Previous food is removed
		for item in bookmarks:
			if item.get_class() == "Rigidbody2D":
				bookmarks.erase(item)
				break
		#New food bookmark is stored
		bookmarks.append(body)
	#Bookmark jumppad
	elif body.get_class() == "Area2D":
		#Previous jumppad bookmarks are removed
		for item in bookmarks:
			if item.get_class == "Area2D":
				bookmarks.erase(item)
				break
		#jumppad is bookmarked
		bookmarks.append(body)
func _on_sight_area_exited(body: Node2D) -> void:
	if body.name == "PlayerBody":
		line_to_player.queue_free()

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
	#Directly to objective
	else:
		direction = directions.front()
		travel_time = travel_times.front()
	$Action_Timer/Time_to_Idle.start(travel_time)
	#Apply movement conditions
	if direction != 0:
		$Appearance.scale.x = -direction
	velocity.x = speed * direction

func made_the_jump():
	var initial_height = self.position.y
	#landed
	if is_on_floor():
		var old_height
		if self.postion.y == old_height:
			pass
	#jumping
	else:
		pass
