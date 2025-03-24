extends StaticBody2D

var selected_item = null
var inventory: Array

@onready var pointer = $Pointer

#HANDLE ITEM DRAGGING
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			#when mouse button is pressed, where you clicked is stored and...
			var event_pos = (event.position / Vector2(2,2)) + Vector2(-635,-72)
			#...we find any colliding items where you clicked.
			selected_item = find_colliding_item(event_pos)
			#if you clicked an item...
			if selected_item != null:
				#...a new pinjoint is made and...
				var grip: PinJoint2D = PinJoint2D.new()
				add_child(grip)
				#...it's parameters are set.
				grip.node_a = pointer
				grip.node_b = selected_item
				grip.softness = 2

#FIND WHAT YOU CLICKED ON
func find_colliding_item(cursor_pos):
	#a collider is moved to your cursor
	pointer.set_position(cursor_pos)
	
	#This code is a total mystery.
	var pointer_collider = pointer.shape_owner_get_shape(0,0)
	var pointer_transform = pointer.get_transform()
	for node in get_node("Items").get_children():
		var item_shape = node.shape_owner_get_shape(0,0)
		var res = item_shape.collide(node.get_transform(), pointer_collider, pointer_transform)
		if res:
			return node
	return null
