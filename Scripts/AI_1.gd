extends CharacterBody2D

#I wonder if the class can be changed for the cat so it can friendly or aggresive
class_name CatAlly

#Speed to determine how fast the creature is
const speed = 15
#determine if cat is chasing player
var is_chasing: bool

#determine current health
var health_current = 10
#max health of cat
var health_max = 10
#the minimum amount of health the cat can have. Determines when dead
var health_min = 0

#determine if cat is dead
var dead: bool = false
#determine if cat is taking damage
var taking_damage: bool = false
#determine amount of damage the cat deals
var damage_to_deal = 20
#determine if cat is dealing damage
var is_dealing_damage: bool = false

#which way the cat moves
var dir: Vector2
#brings cat to ground
const gravity = 900
#how far cat is knocked back when hit
var knockback_force = 200
#determine if the cat is roaming
var is_roaming: bool = true

#uses player information to follow the player
@export var player : CharacterBody2D
var in_player_area: bool = false

func _process(delta):
	#if the cat is off the ground, gravity is applied and the cat will fall straight down.
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	
	if position.x <= player.position.x - 300 or position.x >= player.position.x + 300:
		is_chasing = true
	else:
		is_chasing = false
	
	if position.y >= player.position.y + 500 or position.y <= player.position.y - 500:
		dead = true
	else:
		dead = false
	
	move(delta)
	handle_animation()
	move_and_slide()

#when timer is done, another wait time is determined.
func _on_movement_timer_timeout() -> void:
	$MovementTimer.wait_time = choose([3.0, 4.0, 5.5])
	#if the cat is not chasing the player, they will choose to go left or right
	if !is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func handle_dead():
	if dead == true:
		print (name + " Died :(")
		self.queue_free()

#this function is used to shuffle and output one part of an array.
func choose(array):
	array.shuffle()
	return array.front()

#the cat moves
func move(delta):
	#if the cat is dead, it does not move.
	if !dead:
		#if the cat is not chasing the player, it will move.
		if !is_chasing:
			velocity += dir * speed * delta
		elif is_chasing:
			var dir_to_player = position.direction_to(player.position) * speed * 2
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x) / velocity.x
		is_roaming = true
	#if cat is dead, it will not move.
	elif dead:
		handle_dead()
	if is_roaming == false:
		velocity.x = 0

func handle_animation():
	var anim_sprite = $AnimatedSprite2D
	#all animations unrelated to battling are listed here
	if !dead and !taking_damage and !is_dealing_damage:
		if velocity.x == 0:
			anim_sprite.play("Idle")
		else:
			anim_sprite.play("Walk")
		if dir.x == -1:
			anim_sprite.flip_h = false
		elif dir.x == 1:
			anim_sprite.flip_h = true
