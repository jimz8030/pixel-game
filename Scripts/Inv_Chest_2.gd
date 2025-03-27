extends StaticBody2D

#selected_item is used to define the item that is clicked on
var selected_item = null

#pointer follows cursor and is used to select items
@onready var pointer: RigidBody2D = $Pointer
#grip is a pinjoint that connects the cursor to the item.
@onready var grip: PinJoint2D = $Pointer/Grip

#HANDLE ITEM DRAGGING
func _input(event: InputEvent) -> void:

	#HANDLE DRAGGING ITEM
	if event is InputEventMouseMotion:
		#if mouse moves, the cursor is recorded, ...
		var event_pos = (event.position / Vector2(2,2)) + Vector2(-345,-142)

		#...the cursor follows the mouse, and selected item is defined.
		pointer.set_position(event_pos)
		selected_item = find_colliding_item()

		#if you click and drag over an item, the pinjoint connects the cursor to the item
		if Input.is_action_pressed("Left_Click") and selected_item != null:
			grip.set_node_b(selected_item.get_path())
	#if you are not clicking, the pinjoint is reset, and you cannot select an item.
	if Input.is_action_just_released("Left_Click"):
		grip.set_node_b(pointer.get_path())
		selected_item = null


#DETECT WHAT YOU CLICK ON
func find_colliding_item():
	var collided_thing = pointer.get_colliding_bodies()
	if !collided_thing.is_empty():
		return collided_thing[0]


#KEEP ITEM STILL WHILE IN CHEST
func _on_item_detect_body_entered(body: Node2D) -> void:
	if body.get_class() == "RigidBody2D":
		body.reparent($Items)

func _on_item_detect_body_exited(body: Node2D) -> void:
	if body.get_class() == "RigidBody2D":
		body.set_deferred("reparent", get_tree().get_current_scene())
