extends Sprite2D

#selected_item is used to define the item that is clicked on
var selected_item : Node2D = null

#pointer follows cursor and is used to select items
@onready var pointer: RigidBody2D = $Pointer

var stick_waiting = false

#HANDLE ITEM DRAGGING
func _input(event: InputEvent) -> void:

	#CHECK FOR ITEM
	if event.is_action_pressed("Left_Click"):
		selected_item = find_colliding_item()

	if event is InputEventMouseMotion:
		#get cursor position and make a "feeler" follow it
		var event_pos = (event.position / Vector2(2,2)) + Vector2(-345,-142)
		pointer.set_position(event_pos)

		if selected_item != null:

			#ACTIVELY DRAGGING ITEM
			if Input.is_action_pressed("Left_Click"):
				selected_item.reparent(get_tree().get_current_scene())
				selected_item.freeze = false
				selected_item.get_child(0).set_node_b(pointer.get_path())
				selected_item.collision_layer = 4 | 8
				selected_item.collision_mask = 1 | 4

			#DROPPED ITEM
			elif stick_waiting == false:
				#if no longer clicking, and item is outside the item frame, item drops.
				selected_item.get_child(0).set_node_b(selected_item.get_path())
				selected_item = null
			#ITEM PLACED INSIDE ITEM FRAME
			elif stick_waiting == true:
				selected_item.collision_layer = 8
				selected_item.collision_mask = 8
				#call_deferred performs code when it can, so the rigidbody doesn't break. Other than that, I don't know
				selected_item.freeze = true
				selected_item.reparent($Items)
				stick_waiting = false


#DETECT WHAT YOU CLICK ON
func find_colliding_item():
	var collided_thing = pointer.get_colliding_bodies()
	if !collided_thing.is_empty():
		if collided_thing[0].get_class() == "RigidBody2D":
			return collided_thing[0]


func _on_item_detect_body_entered(body: Node2D) -> void:
	#ITEM FALLS INTO ITEM FRAME
	if selected_item == null:
		var item_collection : Node2D = $Items
		body.collision_layer = 8
		body.collision_mask = 8
		#call_deferred performs code when it can, so the rigidbody doesn't break. Other than that, I don't know
		body.call_deferred("set", "freeze", true)
		body.call_deferred("reparent", item_collection)
	#HOVERING ITEM OVER ITEM FRAME
	else:
		#the item frame anticipates the item being dropped so it can catch it
		stick_waiting = true


func _on_item_detect_body_exited(body: Node2D) -> void:
	stick_waiting = false
