extends CharacterBody2D

# Opinion 3: the creature will not attack.
# Opinion 2: the creature will attack.
@export var player_opinion : float

#Animations
@onready var anim_tree : AnimationTree = $AnimationTree

#Player
@onready var player : CharacterBody2D = $"../PlayerBody"

#used to draw line of sight at the player
var main_sight_line : Node2D

#used to point at items
var second_sight_line : Node2D
var third_sight_line : Node2D
var fourth_sight_line : Node2D

#used to gather nearby items
var nonplayer_body_1 : Node2D
var nonplayer_body_2 : Node2D
var nonplayer_body_3 : Node2D
#used to keep a list of nearby items
var nearby_items : Array


#used to check if player is nearby (or within sight area bounds)
var player_is_near : bool = false

#used to wander left or right
var facing : int

#State checks
var is_chasing : bool = false
var is_roaming : bool = true

#Movement
var speed = 60.0
var jump_force = -300.0

#Stuff to run every frame
func _physics_process(delta: float) -> void:
	
	# CHASE STATE CONDITIONS
	if main_sight_line != null:
		if main_sight_line.is_colliding():
			if main_sight_line.get_collider().name == "PlayerBody":
				#creature chases and attacks only if there opinion of you is low
				if player_opinion < 3 and $Timers/Hunger.get_time_left() > 60:
					chase()
					is_roaming = false
			# Creature loses interest a little after losing sight of the player (hence a timer is used)
			else:
				$"Timers/Interest Cooldown".start()
				
				# Creature moves slowly when searching for the player
				if main_sight_line.target_position.x < 0:
					self.velocity.x = -speed * 0.4
				else:
					self.velocity.x = speed * 0.4
	
	# HUNGRY STATE CONDITIONS
	if $Timers/Hunger.get_time_left() < 120:
		hungry()
	
	#ROAMING STATE CONDITIONS
	if is_roaming == true:
		roaming()
	
	#Make creature face where it moves
	if velocity.x > 0:
		$Sprite2D.scale.x = -1
	elif velocity.x < 0:
		$Sprite2D.scale.x = 1
	
	
	#HANDLE JUMPING
	if is_on_floor():
		if $"JumpCast Right".is_colliding() and velocity.x > 0:
			velocity.y = jump_force
		elif $"JumpCast Left".is_colliding() and velocity.x < 0:
			velocity.y = jump_force
	
	#Animations
	if velocity.x != 0:
		anim_tree["parameters/conditions/is_idle"] = false
		anim_tree["parameters/conditions/is_moving"] = true
	else:
		anim_tree["parameters/conditions/is_idle"] = true
		anim_tree["parameters/conditions/is_moving"] = false
		
	
	# Gravity and movement.
	if !is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


#LINES OF SIGHT
func _on_crumb_timer_timeout() -> void:

	#PLAYER SPECIFIC SIGHT LINE
	if player_is_near:
		#if there isn't already a player line of sight, one is made
		if main_sight_line == null:
			main_sight_line = RayCast2D.new()
			#raycast scans on the map layer and the player layer
			main_sight_line.collision_mask = 1 | 2
			self.add_child(main_sight_line)
		main_sight_line.target_position = Vector2((player.position.x - self.position.x) * 1.1, (player.position.y - self.position.y) * 1.1)

	else:
		#the line of sight is removed if not already
		if main_sight_line != null:
			main_sight_line.queue_free()


	#ITEM SPECIFIC SIGHT LINES
	for count in range(nearby_items.size()):

		#ITEM LINE 1
		# Initial item raycast is drawn (draws line if there isn't one already)
		if second_sight_line == null:
			second_sight_line = RayCast2D.new()
			second_sight_line.collision_mask = 1 | 4
			self.add_child(second_sight_line)

		# If there is one item, the second item line is not needed
		#and if the line is not already removed
		if nearby_items.size() == 1 and third_sight_line != null:
			third_sight_line.queue_free()

		#sight line points at it's assigned item
		if second_sight_line != null:
			second_sight_line.target_position = Vector2((nearby_items[0].position.x - self.position.x) * 1.1, (nearby_items[0].position.y - self.position.y) * 1.1)

		#ITEM LINE 2
		#if there are two items nearby...
		if nearby_items.size() == 2:
			#store location of second item nearby
			nonplayer_body_2 = nearby_items[1]

			# A second sight line is made if there isn't one already (called "third" because first line is for player)
			if third_sight_line == null:
				third_sight_line = RayCast2D.new()
				third_sight_line.collision_mask = 1 | 4
				self.add_child(third_sight_line)

			#if there are two items nearby, the third item line is not needed
			#it's removed if not already
			if fourth_sight_line != null:
				fourth_sight_line.queue_free()

			#sight line points at it's assigned item
			if third_sight_line != null:
				third_sight_line.target_position = Vector2((nearby_items[1].position.x - self.position.x) * 1.1, (nearby_items[1].position.y - self.position.y) * 1.1)

		#ITEM LINE 3
		# If there are three items nearby...
		elif nearby_items.size() == 3:
			#store location of third item nearby
			nonplayer_body_2 = nearby_items[1]

			# A third item sight line if made (called "fourth" because first line is for player)
			if fourth_sight_line == null:
				third_sight_line = RayCast2D.new()
				third_sight_line.collision_mask = 1 | 4
				self.add_child(third_sight_line)

			#sight line points at it's assigned item
			if fourth_sight_line != null:
				fourth_sight_line.target_position = Vector2((nearby_items[2].position.x - self.position.x) * 1.1, (nearby_items[2].position.y - self.position.y) * 1.1)

	#remove the first sight line if there are no items nearby
	#and if it isn't already removed (needs to be outside the for loop)
	if nearby_items.is_empty() and second_sight_line != null:
		second_sight_line.queue_free()
#PERSONAL BUBBLE
func _on_sight_area_body_entered(body: Node2D) -> void:
	if body.name == "PlayerBody":
		#signal sent to function above
		player_is_near = true
	if body.get_class() == "RigidBody2D":
		nearby_items.append(body)
func _on_sight_area_body_exited(body: Node2D) -> void:
	if body.name == "PlayerBody":
		#signal sent to function above
		player_is_near = false
	if body.name != "PlayerBody":
		nearby_items.erase(body)


# STATE: CHASE
func chase():

	# Creature reacts faster while chasing
	$"Timers/Reaction Time".wait_time = 0.6

	# Move towards player
	if main_sight_line.target_position.x < 0:
		self.velocity.x = -speed
	elif main_sight_line.target_position.x > 0:
		self.velocity.x = speed
#EXITING CHASE
func _on_detection_cooldown_timeout() -> void:
	#after 3 seconds, the AI loses interest in chasing the player.
	$"Timers/Reaction Time".wait_time = 1
	roaming()
	pass


#STATE: HUNGRY
func hungry():

	#food is nearby (there's an item in the nearby items array)
	if !nearby_items.is_empty():

		#wanders faster when hungry and no food is nearby
		if nearby_items.is_empty():
			speed = 80.0

			#slime approaches food slowly if food is held by player
			if nearby_items[0].get_collider().get_child(0).node_b != nearby_items[0].get_collider().get_path():
				speed = 30.0
			else:
				speed = 60.0

			#slime runs after food
			if nearby_items[0].target_position.x < 0:
				self.velocity.x = -speed
			elif nearby_items[0].target_position.x > 0:
				self.velocity.x = speed
#creature eats food next to itself
func _on_consume_area_body_entered(body: Node2D) -> void:
	if $Timers/Hunger.get_time_left() < 180 and body.edible == true:
		#if food is being held by player
		if body.get_child(0).node_b != body.get_path():
			#opinion goes up when eating fruit from player's hand
			player_opinion += 0.35
			print (player_opinion)
		#food is eaten (item removed)
		body.queue_free()
		#hungry no more (hunger timer restarts)
		$Timers/Hunger.start()

	#remove secondary line of sight
	if second_sight_line != null:
		second_sight_line.queue_free()
		speed = 60.0
#Creature starved.
func _on_hunger_timeout() -> void:
	dead()


#STATE: DEAD
func dead():
	self.queue_free()


#STATE: WANDERING
func roaming():
	is_roaming = true
	self.velocity.x = speed * facing * 0.5
#Determine wandering direction
func _on_wander_timer_timeout() -> void:
	if is_roaming:
		$"Timers/Wander Timer".wait_time = choose([3.0, 4.0, 5.5])
		facing = choose([-1, 0, 1])
#used to choose one part of an array
func choose(array):
	array.shuffle()
	return array.front()
