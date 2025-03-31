extends Area2D


#if player is inside, the pad will wait until the player jumps to boost them
var player_body : CharacterBody2D

#determines how far things are thrown
@export var jump_boost = 500


func _on_body_entered(body: Node2D) -> void:
	#if the body's collision layer matches the player's (or is the player)
	#...player_body stores the body for later use
	if body.collision_layer == 2:
		player_body = body

	#if the body matches the item collision layer (or is an item)...
	#why is it layer 12? I don't know, I just checked the item collision layer and it was 12...
	if body.collision_layer == 12 and !Input.is_action_pressed("Left_Click"):
		#...the item is disconnected from the cursor and is thrown upwards
		body.get_child(0).set_node_b(body.get_path())
		#apply_impulse works with rigidbody2D, it calls for 2 vector2s
		#one vector is the amount of force, and the other is where that force is applied on the object
		#I use mass to even out how far the item flies up. If I don't, light objects fly further than heavier objects.
		body.apply_impulse(Vector2(0, -jump_boost * body.mass), Vector2(0,0))

func _on_body_exited(body: Node2D) -> void:
	#player left the jump pad
	if body.collision_layer == 2:
		player_body = null


func _process(_delta: float) -> void:
	if player_body != null:
		if player_body.velocity.y < 0:
			player_body.velocity.y = -jump_boost
