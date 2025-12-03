extends Sprite2D

#selected_item is used to define the item that is clicked on
var selected_item : Node2D = null

#pointer follows cursor and is used to select items
@onready var line_of_sight_1: RayCast2D = $Line_of_Sight_1
@onready var line_of_sight_2: RayCast2D = $Line_of_Sight_2
@onready var lift_line: Path2D = $Lift_Line

#Used to figure out where stored items go
var available_slot : Control

#Used to determine where the cursor goes while dragging on inventory slots
var cursor_initial_pos = null
#Stores item details from the slot
var inv_selected_item = null

#HANDLE ITEM DRAGGING
func _input(event: InputEvent) -> void:

	#Toggle Inventory
	if event.is_action_pressed("Inventory"):
		if $Slots.visible == true:
			$Slots.visible = false
		else:
			$Slots.visible = true

	#CHECK FOR ITEM
	if event.is_action_pressed("Left_Click"):

		#Feel for an item
		if line_of_sight_1.is_colliding():
			if line_of_sight_1.get_collider() != null:
				if line_of_sight_1.get_collider().get_class() == "RigidBody2D":
					selected_item = find_colliding_item()
			elif line_of_sight_2.is_colliding():
				if line_of_sight_2.get_collider().get_class() == "RigidBody2D":
					selected_item = find_colliding_item()
		elif line_of_sight_2.get_collider() != null:
			if line_of_sight_2.get_collider().get_class() == "RigidBody2D":
				selected_item = find_colliding_item()

		#Turn on animal stats
		var animal_stats : ColorRect
		if !$Pointer.get_colliding_bodies().is_empty():
			if get_node($Pointer.get_colliding_bodies()[0].get_path()).get_class() == "CharacterBody2D":
				animal_stats = get_node($Pointer.get_colliding_bodies()[0].get_path()).get_child(0)
				$"../..".animal_being_tamed = $Pointer.get_colliding_bodies()[0]
				if animal_stats.visible == true:
					animal_stats.visible = false
				else:
					animal_stats.visible = true

		#Figure out what slot the object would go to
		for slot in $Slots.get_children():
			#reset the available slot
			available_slot = null
			#search through slots for an opening
			if slot.get_child_count() == 1:
				available_slot = slot
				break

	if event is InputEventMouseMotion:
		
		#get cursor position and make a "feeler" (or the pointer) follow it
		$Pointer.set_position(get_local_mouse_position())
		#lines are drawn near the cursor and used to determine if there's anything in the way
		line_of_sight_1.set_target_position((get_local_mouse_position() + Vector2(-22,-33)) * 1.1)
		line_of_sight_2.set_target_position((get_local_mouse_position() + Vector2(-22,-37)) * 1.1)

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
					selected_item.collision_mask = 1 | 4
				
				#DRAW EFFORT CURVE
				lift_line.curve.set_point_position(1, selected_item.position - $"..".position + Vector2(18,60))
				lift_line.curve.set_point_out(0, $Pointer.position)
				lift_line.curve.set_point_position(0, line_of_sight_2.position)

			#item drops if there are no slots
			else:
				selected_item.get_child(0).set_node_b(selected_item.get_path())
				selected_item = null
				lift_line.curve.set_point_position(1, Vector2(0, 41))

			if selected_item != null:
				if selected_item.position.distance_to(get_parent().position) > 300:
					selected_item.get_child(0).set_node_b(selected_item.get_path())
					selected_item = null
					lift_line.curve.set_point_position(1, Vector2(0, 41))

	#STORE ITEM
	if event.is_action_pressed("Store") and selected_item != null:
		if selected_item.eat_heal_amount > 0 or selected_item.equipable:
			if available_slot != null:
				#item's collisions are set to no longer collide with the map
				selected_item.collision_layer = 8
				selected_item.collision_mask = 8
				selected_item.z_index = 1
				#Selected item is no longer attached to the cursor
				selected_item.get_child(0).set_node_b(selected_item.get_path())
				#call_deferred performs code when it can, so the rigidbody doesn't break. Other than that, I don't know
				selected_item.freeze = true
				#item is reparented to the available slot
				selected_item.reparent(available_slot)
				selected_item.call_deferred("set", "position", available_slot.get_child(0).position + Vector2(9,9))
				selected_item.call_deferred("set", "rotation", 0)
				lift_line.curve.set_point_position(1, Vector2(0, 41))
				selected_item = null
			#Drop item if there are no more slots
			else:
				selected_item.get_child(0).set_node_b(selected_item.get_path())
				selected_item = null
				lift_line.curve.set_point_position(1, Vector2(0, 41))

	#DROP OR USE INVENTORY ITEM
	if cursor_initial_pos != null:
		var cursor_current_pos = get_global_mouse_position()
		if cursor_current_pos.x - cursor_initial_pos.x > 10 or cursor_current_pos.x - cursor_initial_pos.x < -10:
			var button_to_disable_num
			for slot in $Slots.get_children():
				if slot.get_child(0).button_pressed:
					button_to_disable_num = int(slot.name.left(5))
					break
			_on_slot_up(button_to_disable_num)
			return
		
		#DROP ITEM
		if event is InputEventMouseMotion and cursor_current_pos.y - cursor_initial_pos.y > 10:
			#reparent item to scene (item no longer follows item frame)
			selected_item = inv_selected_item
			var button_to_disable_num
			for slot in $Slots.get_children():
				if slot.get_child(0).button_pressed:
					button_to_disable_num = int(str(slot.name)[5])
					break
			_on_slot_up(button_to_disable_num)
		
		#EQUIP OR EAT ITEM
		if event.is_action_released("Left_Click") and cursor_current_pos.y - cursor_initial_pos.y < -10:
			if cursor_initial_pos != null and inv_selected_item != null:
				#EQUIP ITEM
				if inv_selected_item.equipable:
					get_parent().equipped_item = inv_selected_item
					inv_selected_item.freeze = true
					inv_selected_item.get_child(2).disabled = true
					inv_selected_item.reparent(get_parent().get_node("Appearance/Top_Clothing"))
					inv_selected_item.z_index = -1
					get_parent().get_node("Appearance/Top_Clothing").get_child(0).position = Vector2(0,0)
					get_parent().get_node("Appearance/Top_Clothing").get_child(0).rotation = 45
				#EAT ITEM
				elif inv_selected_item.eat_heal_amount > 0:
					get_parent().get_child(0).value += inv_selected_item.eat_heal_amount
					lift_line.curve.set_point_position(1, Vector2(0, 41))
					inv_selected_item.queue_free()
				inv_selected_item = null
	queue_redraw()

#DRAW LIFT LINE
func _draw() -> void:
	#Grabbing item
	if selected_item != null:
		draw_polyline($Lift_Line.curve.get_baked_points(), Color(0.27,0.83,0.9,0.5), 1.5)
	#Canonot grab item
	elif Input.is_action_pressed("Left_Click"):
		draw_line(line_of_sight_2.position, (line_of_sight_2.target_position - self.position) / 1.1, Color(0.78,0,0.82,0.5), 1.5)

#DETECT WHAT YOU CLICK ON
func find_colliding_item():
	#if the array stored something, then it returns the first item in the list.
	if !$Pointer.get_colliding_bodies().is_empty():
		if get_node($Pointer.get_colliding_bodies()[0].get_path()).get_class() == "RigidBody2D":
			return $Pointer.get_colliding_bodies()[0]

#Recieving slot signals
func _on_slot_up(slot_num: int) -> void:
	var slot_pressed : Control = get_node("Slots/Slot_" + str(slot_num))
	for label in slot_pressed.get_child(0).get_children():
		label.visible = false
	inv_selected_item = null
	cursor_initial_pos = null
func _on_slot_down(slot_num: int) -> void:
	var slot_pressed : Control = get_node("Slots/Slot_" + str(slot_num))
	if slot_pressed.get_child_count() == 2:
		inv_selected_item = slot_pressed.get_child(1)
		available_slot = inv_selected_item.get_parent()
		cursor_initial_pos = get_global_mouse_position()
		for label in slot_pressed.get_child(0).get_children():
			label.visible = true
