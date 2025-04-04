extends Sprite2D

#selected_item is used to define the item that is clicked on
var selected_item : Node2D = null

#pointer follows cursor and is used to select items
@onready var pointer: RigidBody2D = $Pointer

#used to anticipate item being placed inside item frame while item is hovering over the item frame
var stick_waiting = false

#HANDLE ITEM DRAGGING
func _input(event: InputEvent) -> void:

	#CHECK FOR ITEM
	if event.is_action_pressed("Left_Click"):
		#find what you click on (see function below)
		selected_item = find_colliding_item()

	if event is InputEventMouseMotion:
		#get cursor position and make a "feeler" (or the pointer) follow it
		var event_pos = (event.position / Vector2(2,2)) + Vector2(-345,-148)
		pointer.set_position(event_pos)

		#declares that there is an item to select
		if selected_item != null:

			#ACTIVELY DRAGGING ITEM
			if Input.is_action_pressed("Left_Click"):
				
				#reparent item to scene (item no longer follows item frame)
				selected_item.reparent(get_tree().get_current_scene())
				#item is not frozen (item's rigidbody is active)
				selected_item.freeze = false
				#item follows cursor (or a pointer following the cursor)
				selected_item.get_child(0).set_node_b(pointer.get_path())
				#item collision changes to collide with the world
				selected_item.collision_layer = 4
				selected_item.collision_mask = 1 | 4 | 8

			#DROPPED ITEM
			elif stick_waiting == false:
				#if no longer clicking, and item is outside the item frame, item drops.
				selected_item.get_child(0).set_node_b(selected_item.get_path())
				selected_item = null

			#ITEM PLACED INSIDE ITEM FRAME
			elif stick_waiting == true:
				#item's collisions are set to no longer collide with the map
				selected_item.collision_layer = 8
				selected_item.collision_mask = 8
				#call_deferred performs code when it can, so the rigidbody doesn't break. Other than that, I don't know
				selected_item.freeze = true
				#item is reparented to the item frame (item follows item frame)
				selected_item.reparent($Items)
				#after code is ran, the item frame no longer anticipates an item being placed inside.
				stick_waiting = false


#DETECT WHAT YOU CLICK ON
func find_colliding_item():
	#a list of items colliding with the cursor (or pointer/feeler) is gathered
	var collided_thing = pointer.get_colliding_bodies()
	#if the array stored something, then it returns the first item in the list.
	if !collided_thing.is_empty():
		return collided_thing[0]


func _on_item_detect_body_entered(body: Node2D) -> void:

	#ITEM FALLS INTO ITEM FRAME
	if selected_item == null and body.collectable:
		#get item parent beforehand to help aleviate pressure on code
		var item_collection : Node2D = $Items
		#reset collision layers so the item doesn't collide with the world while in the frame
		body.collision_layer = 8
		body.collision_mask = 8
		#freeze and reparent item to node declared above
		#call_deferred performs code when it can, so the rigidbody doesn't break. Other than that, I don't know
		body.call_deferred("set", "freeze", true)
		body.call_deferred("reparent", item_collection)

	#HOVERING ITEM OVER ITEM FRAME
	elif body.collectable:
		#the item frame anticipates the item being dropped so it can catch it
		stick_waiting = true

#ITEM OUTSIDE ITEM FRAME
func _on_item_detect_body_exited(_body) -> void:
	#if the item left the frame, then...
	#...the item frame does not anticipate an item being placed inside
	stick_waiting = false
