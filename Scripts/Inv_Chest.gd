extends Node2D

var selected_item = null

var inventory : Array

#HANDLE ITEM DRAGGING
func _input(event):
	#check if the object is being interacted with
	if event is InputEventMouseButton:
		#check if the interaction is clicking
		if event.is_pressed():
			var event_pos = (event.position / Vector2(2,2)) + Vector2(-635,-72)
			selected_item = find_colliding_item(event_pos)
			if selected_item == null:
				return
			selected_item.dragging_item = true
		#check if the mouse button has been released
		elif event.is_released() and selected_item != null:
			selected_item.dragging_item = false
			#extra nudge to wake up the item's physics
			selected_item.apply_impulse(Vector2(0,0), Vector2(0,1))
			for node in get_node("Items").get_children():
				node.set_sleeping(false)
			selected_item = null

	elif event is InputEventMouseMotion and selected_item != null:
		#if mouse is moving and we're holding the mouse button down, we move the item.
		
		#setting the item's position breaks it's physics unless we do it during it's physics processing.
		#check the "item_physics" script to see how that is done.
		if selected_item.translate_by == null:
			selected_item.translate_by = Vector2(0,0)

		#ITEM POSITION IS APPLIED HERE
		selected_item.translate_by += event.get_relative() / Vector2(2,2)
		for node in get_node("Items").get_children():
			node.set_sleeping(false)

func find_colliding_item(cursor_pos):
	var pointer = $Pointer
	pointer.set_position(cursor_pos)
	var pointer_collider = pointer.shape_owner_get_shape(0,0)
	var pointer_transform = pointer.get_transform()
	
	for node in get_node("Items").get_children():
		var item_shape = node.shape_owner_get_shape(0,0)
		var res = item_shape.collide(node.get_transform(), pointer_collider, pointer_transform)
		if res:
			return node
	return null

func _on_item_detection_body_entered(body: Node2D) -> void:
	if body.get_class() == "RigidBody2D":
		inventory.append(body.name)
		body.get_child(0).scale = Vector2(1.6,1.6)


func _on_item_detection_body_exited(body: Node2D) -> void:
	if body.get_class() == "RigidBody2D":
		inventory.erase(body.name)
		body.get_child(0).scale = Vector2(1,1)
