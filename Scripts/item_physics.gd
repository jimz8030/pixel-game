extends RigidBody2D
class_name Inv_Item

#when dragging the item outside of it's rigidbody physics, the physics are broken, and the item does not fall.
#this script is used to drag the item while it's physics are taking place, so the physics do not break.

#this variable determines how far we want to move the object (see below)
var translate_by = null
#this variable is being changed in the "Inv_Item" script.
var dragging_item = false

#This function allows us to modify the item during the physics process
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#when faling, the item falls faster and faster, so if we're dragging it, we need the falling velocity to remain 0.
	if dragging_item:
		state.set_linear_velocity(Vector2(0,-10))
		state.set_angular_velocity(0)
	
		# we do stuff only if translate by is modified by another object's script
		if translate_by != null:
			#the transform of the item allows us to modify its rotation and position
			var item_pos = state.get_transform()
			#the rotation will stay the same, but the position will be added onto by however far we want to drag the item.
			state.set_transform(Transform2D(item_pos.get_rotation(), item_pos.get_origin() + translate_by))
			#the velocity will continue to apply even after we release unless we reset the
			#variable we use to translate the item.
			translate_by = null
