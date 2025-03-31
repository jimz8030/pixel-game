extends CharacterBody2D

#used to find the player
var main_sight_line : Node2D

#both used to find items
var second_sight_line : Node2D
var nonplayer_body : Node2D

#used to check what is nearby (within sight area bounds)
var player_is_near : bool = false
var other_is_near : bool = false

#used to start the chase scene
var can_see_player : bool = false

var is_chasing : bool = false
var is_wandering : bool = true

var speed = 60.0

@onready var anim_tree : AnimationTree = $AnimationTree
@onready var player : CharacterBody2D = $"../PlayerBody"

func _physics_process(delta: float) -> void:
	
	#Reports if we can see the player
	if main_sight_line != null:
		if main_sight_line.is_colliding():
			# If the player is within the line of sight then we can see the player, and we are chasing the player
			if main_sight_line.get_collider().name == "PlayerBody":
				can_see_player = true
				is_chasing = true
			#if the object in sight is not the player then we cannot see the player
			elif main_sight_line.get_collider().name != "PlayerBody":
				can_see_player = false
	else:
		is_wandering = true
	
	#going right
	if velocity.x > 0:
		$Sprite2D.scale.x = -1
	#going left
	elif velocity.x < 0:
		$Sprite2D.scale.x = 1
	
	#ANIMATIONS
	if velocity.x != 0:
		anim_tree["parameters/conditions/is_idle"] = false
		anim_tree["parameters/conditions/is_moving"] = true
	else:
		anim_tree["parameters/conditions/is_idle"] = true
		anim_tree["parameters/conditions/is_moving"] = false
		
	
	# Add the gravity.
	if !is_on_floor():
		velocity += get_gravity() * delta
	
	#STATES LIST
	chase()
	
	#needed to move around
	move_and_slide()


func _on_crumb_timer_timeout() -> void:
	#every second, a line is pointed at whatever is nearby and determines whether a player is near
	if player_is_near:
		#if there isn't already a line of sight, one is made
		if main_sight_line == null:
			main_sight_line = RayCast2D.new()
			#raycast scans on the map layer (to see if slime has direct line of sight of player) and the player layer
			main_sight_line.collision_mask = 1 | 2
			self.add_child(main_sight_line)
		main_sight_line.target_position = Vector2((player.position.x - self.position.x) * 1.1, (player.position.y - self.position.y) * 1.1)

	else:
		#the line of sight is removed if not already
		if main_sight_line != null:
			can_see_player = false
			main_sight_line.queue_free()

	#a different line is produced to determine if an item is nearby
	if other_is_near:
		if second_sight_line == null:
			second_sight_line = RayCast2D.new()
			second_sight_line.collision_mask = 1 | 4
			self.add_child(second_sight_line)
		#line of sight points at the player
		second_sight_line.target_position = Vector2((nonplayer_body.position.x - self.position.x) * 1.1, (nonplayer_body.position.y - self.position.y) * 1.1)

	else:
		#the line of sight is removed if not already
		if main_sight_line != null:
			can_see_player = false
			main_sight_line.queue_free()

# Reports if the player is near or if something else is near.
func _on_sight_area_body_entered(body: Node2D) -> void:
	if body.name == "PlayerBody":
		player_is_near = true
	if body.name != "PlayerBody" and body != self:
		other_is_near = true
		nonplayer_body = body

func _on_sight_area_body_exited(body: Node2D) -> void:
	if body.name == "PlayerBody":
		player_is_near = false
	if body.name != "PlayerBody":
		other_is_near = false

#STATE: CHASE
func chase():
	#checks to see if chasing is true
	if is_chasing:
		is_wandering = false
		$"Timers/Reaction Time".wait_time = 0.6
		#if we can see the player...
		if can_see_player:
			#...interest in chasing is maintained
			$"Timers/Interest Cooldown".stop()
			# and we chase after the player
			if main_sight_line.target_position.x < 0:
				self.velocity.x = -speed
			elif main_sight_line.target_position.x > 0:
				self.velocity.x = speed
		# if we can't see the player...
		else:
			#start to lose interest and get to the last place we saw the player
			if $"Timers/Interest Cooldown".is_stopped():
				$"Timers/Interest Cooldown".start()
			#if the player is nearby...
			if main_sight_line != null:
				#...then we approach the last place we saw them.
				if main_sight_line.target_position.x < 0:
					self.velocity.x = -speed * 0.4
				elif main_sight_line.target_position.x > 0:
					self.velocity.x = speed * 0.4
	#if we're not chasing, we're just hanging out.
	else:
		$"Timers/Reaction Time".wait_time = 1
		is_wandering = true

func _on_detection_cooldown_timeout() -> void:
	#after 3 seconds, the AI loses interest in chasing the player.
	is_chasing = false
	is_wandering = true

#HANDLE WANDERING
func _on_wander_timer_timeout() -> void:
	if is_wandering:
		$"Timers/Wander Timer".wait_time = choose([3.0, 4.0, 5.5])
		var facing : int = choose([-1, 0, 1])
		if $"Wall Detect Left".is_colliding() or $"Wall Detect Right".is_colliding():
				velocity.x = speed * facing * 0.2
		else:
			velocity.x = speed * facing

#used to choose one part of an array
func choose(array):
	array.shuffle()
	return array.front()
