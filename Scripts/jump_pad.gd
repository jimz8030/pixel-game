extends Area2D


#if player is inside, the pad will wait until the player jumps to boost them
var player_body : CharacterBody2D

#determines how far things are thrown
@export var jump_boost = 500
@onready var anim_tree = $AnimationTree


func _on_body_entered(body: Node2D) -> void:
	var possible_jump = randi_range(1,3)

	anim_tree["parameters/conditions/is_idle"] = false
	
	
	#if the body's collision layer matches the player's (or is the player)
	#...player_body stores the body for later use
	if body.collision_layer == 2:
		player_body = body
		anim_tree["parameters/conditions/pressure_released"] = false
		anim_tree["parameters/conditions/is_prep"] = true
	
	#if the body is a creature, there's a chance that the creature jumps.
	elif body.collision_layer == 32:
		anim_tree["parameters/conditions/is_prep"] = true
		if possible_jump <= 2:
			body.velocity.x *= 2
			body.velocity.y = -jump_boost
			anim_tree["parameters/conditions/pressure_released"] = true
			anim_tree["parameters/conditions/is_prep"] = false
			
			

	#if the body matches the item collision layer (or is an item)...
	if body.collision_layer == 12 and !Input.is_action_pressed("Left_Click"):
		#apply_impulse works with rigidbody2D
		#I use mass to even out how far the item flies up. If I don't, light objects fly further than heavier objects.
		body.apply_impulse(Vector2(0, -jump_boost * body.mass), Vector2(0,0))

func _on_body_exited(body: Node2D) -> void:
	#player left the jump pad
	if body.collision_layer == 2:
		player_body = null
	anim_tree["parameters/conditions/is_idle"] = true
	anim_tree["parameters/conditions/pressure_released"] = false
	anim_tree["parameters/conditions/is_prep"] = false


func _process(_delta: float) -> void:
	if player_body != null:
		if player_body.velocity.y < 0:
			player_body.velocity.y = -jump_boost
			anim_tree["parameters/conditions/pressure_released"] = true
			anim_tree["parameters/conditions/is_prep"] = false
			
			
