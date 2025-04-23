extends Area2D

#used when the object is a connectable device (such as a chest)
var connected_device : RigidBody2D
#used when a single item is connected to the dispenser
var single_item : RigidBody2D
#used when object is being hovered over the connection point
var possible_connection : RigidBody2D

var count : int

# Detect a device that is hovering over the area
func _on_body_entered(body: Node2D) -> void:
	if body.get_class() == "RigidBody2D":
		possible_connection = body

func _input(event: InputEvent) -> void:
	if event.is_action_released("Left_Click"):
		if possible_connection != null:

			#SINGLE ITEM ATTACHED
			if possible_connection.collectable and single_item == null:
				single_item = possible_connection
				single_item.reparent($Holder)
				single_item.freeze = true
				$AnimationTree["parameters/conditions/connected"] = true
				$AnimationTree["parameters/conditions/not_connected"] = false

				$Production.start()

			#DEVICE ATTACHED
			elif possible_connection.attachable and connected_device == null:
				connected_device = possible_connection
				connected_device.call_deferred("reparent", $Holder)
				connected_device.call_deferred("set", "freeze", true)
				$AnimationTree["parameters/conditions/connected"] = true
				$AnimationTree["parameters/conditions/not_connected"] = false

				$Production.start()

func _on_body_exited(body: Node2D) -> void:
	if body == possible_connection:
		possible_connection = null

#ACTIVELY DISPENSING
func _on_production_timeout() -> void:
	
	#DISPENSING FROM DEVICE
	if connected_device != null:
		connected_device.rotation = 0
		connected_device.position = Vector2(0,0)
		
		var device_inv = connected_device.held_items
		if device_inv[count] != null:
			var item = device_inv[count].instantiate()
			#item is placed in the current scene
			get_tree().current_scene.add_child(item)
			item.position = self.position
			item.apply_central_impulse(Vector2(0,50))
			#item is removed from the device's array
			device_inv.remove_at(count)
			device_inv.resize(device_inv.size() + 1)
			
		if count == device_inv.size() - 1:
			$AnimationTree["parameters/conditions/connected"] = false
			$AnimationTree["parameters/conditions/not_connected"] = true
			
			$Production.stop()
			
		count += 1
	
	#DISPENSING SINGLE ITEM
	else:
		single_item.rotation = 0
		single_item.position = Vector2(0,0)
		single_item.reparent(get_tree().current_scene)
		single_item.position = self.position
		single_item.freeze = false
		single_item.apply_central_impulse(Vector2(0,50))
		single_item = null
		
		$AnimationTree["parameters/conditions/connected"] = false
		$AnimationTree["parameters/conditions/not_connected"] = true
		
		$Production.stop()
