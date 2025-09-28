extends Sprite2D

#selected_item is used to define the item that is clicked on
var selected_item : Node2D = null

#pointer follows cursor and is used to select items
@onready var line_of_sight_1: RayCast2D = $Line_of_Sight_1
@onready var line_of_sight_2: RayCast2D = $Line_of_Sight_2
@onready var lift_line: Path2D = $Lift_Line

#used to anticipate item being placed inside item frame while item is hovering over the item frame
var stick_waiting = false

#HANDLE ITEM DRAGGING
func _input(event: InputEvent) -> void:

	#CHECK FOR ITEM
	if event.is_action_pressed("Left_Click"):
		if line_of_sight_1.get_collider() != null:
			if line_of_sight_1.get_collider().get_class() == "RigidBody2D":
				selected_item = find_colliding_item()
		elif line_of_sight_2.get_collider() != null:
			if line_of_sight_2.get_collider().get_class() == "RigidBody2D":
				selected_item = find_colliding_item()

	if event is InputEventMouseMotion:
		
		#get cursor position and make a "feeler" (or the pointer) follow it
		$Pointer.set_position(get_local_mouse_position())
		line_of_sight_1.set_target_position((get_local_mouse_position() + Vector2(4,-34)) * 1.1)
		line_of_sight_2.set_target_position((get_local_mouse_position() + Vector2(4,-28)) *1.1)

		#declares that there is an item to select
		if selected_item != null:

			#ACTIVELY DRAGGING ITEM
			if Input.is_action_pressed("Left_Click"):
				#reparent item to scene (item no longer follows item frame)
				selected_item.reparent(get_tree().get_current_scene())
				#item is not frozen (item's rigidbody is active)
				selected_item.freeze = false
				#item follows cursor (or a pointer following the cursor)
				selected_item.get_child(0).set_node_b($Pointer.get_path())
				#item collision changes to collide with the world
				if selected_item.collectable or selected_item.attachable:
					selected_item.collision_layer = 4
					selected_item.collision_mask = 1 | 4 | 8
				
				#DRAW EFFORT CURVE
				lift_line.curve.set_point_position(1, selected_item.position - $"..".position + Vector2(0,50))
				lift_line.curve.set_point_out(0, $Pointer.position)
				lift_line.curve.set_point_position(0, Vector2(-2,45))

			#DROPPED ITEM
			elif stick_waiting == false:
				#if no longer clicking, and item is outside the item frame, item drops.
				selected_item.get_child(0).set_node_b(selected_item.get_path())
				selected_item = null
				lift_line.curve.set_point_position(1, Vector2(0, 41))

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
				lift_line.curve.set_point_position(1, Vector2(0, 41))

			if selected_item != null:
				if selected_item.position.distance_to(get_parent().position) > 300:
					selected_item.get_child(0).set_node_b(selected_item.get_path())
					selected_item = null
					lift_line.curve.set_point_position(1, Vector2(0, 41))
	queue_redraw()

	#EAT OR EQUIP ITEM
	#ITEM IN FRAME
	if event.is_action_pressed("Use") and selected_item == null:
		if $Items.get_child_count() > 0:
			#EAT ITEM
			if $Items.get_child(0).eat_heal_amount > 0:
				get_parent().current_health += $Items.get_child(0).eat_heal_amount
				lift_line.curve.set_point_position(1, Vector2(0, 41))
				$Items.get_child(0).queue_free()
			#EQUIP ITEM
			elif $Items.get_child(0).equipable:
				get_parent().equipped_item = $Items.get_child(0)
				$Items.get_child(0).freeze = true
				$Items.get_child(0).get_child(2).disabled = true
				$Items.get_child(0).reparent(get_parent().get_node("Appearance/Top_Clothing"))
				get_parent().get_node("Appearance/Top_Clothing").get_child(0).position = Vector2(0,0)
				get_parent().get_node("Appearance/Top_Clothing").get_child(0).rotation = 45
	
	#HOLDING ITEM
	elif event.is_action_pressed("Use") and selected_item != null:
		#EAT ITEM
		if selected_item.eat_heal_amount > 0:
			get_parent().current_health += selected_item.eat_heal_amount
			lift_line.curve.set_point_position(1, Vector2(0, 41))
			selected_item.queue_free()
		#EQUIP ITEM
		elif selected_item.equipable:
			get_parent().equipped_item = selected_item
			selected_item.freeze = true
			selected_item.get_child(2).disabled = true
			selected_item.reparent(get_parent().get_node("Appearance/Top_Clothing"))
			get_parent().get_node("Appearance/Top_Clothing").get_child(0).position = Vector2(0,0)
			get_parent().get_node("Appearance/Top_Clothing").get_child(0).rotation = 45
		selected_item = null


#DRAW LIFT LINE
func _draw() -> void:
	if selected_item != null:
		draw_polyline($Lift_Line.curve.get_baked_points(), Color(0.27,0.83,0.9,0.5), 1.5)
	elif Input.is_action_pressed("Left_Click") and !$Pointer.get_colliding_bodies().is_empty():
				draw_line(Vector2(0,41), line_of_sight_2.target_position + Vector2(4,32), Color(0.78,0,0.82,0.5), 1.5)

#DETECT WHAT YOU CLICK ON
func find_colliding_item():
	#a list of items colliding with the cursor (or pointer/feeler) is gathered
	var collided_things = $Pointer.get_colliding_bodies()
	#if the array stored something, then it returns the first item in the list.
	if !collided_things.is_empty():
		return collided_things[0]

#ITEM INSIDE ITEM FRAME
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
