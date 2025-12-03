extends RigidBody2D

@export var item_name : String
@export var collectable : bool
@export var eat_heal_amount : int
@export var attachable : bool
@export var equipable : bool

@export var stored_item : PackedScene

func _on_body_entered(body: Node) -> void:
	if (self.linear_velocity.x > 150 or self.linear_velocity.y > 150 \
	or self.linear_velocity.x < -150 or self.linear_velocity.y < -150):
		$Condense_Break_Signal.start()

func _on_condense_break_signal_timeout() -> void:
	break_open()

func break_open():
	if $Sprite2D.frame >= 3:
		if stored_item != null:
			var item_released = stored_item.instantiate()
			$"..".add_child(item_released)
			item_released.position = self.position
			item_released.apply_impulse(Vector2(self.linear_velocity.x, -100))
		self.queue_free()
	else:
		$Sprite2D.frame += 3
	$Condense_Break_Signal.stop()

#Jump on Crate
func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.velocity.y > 0:
		break_open()
		body.velocity.y = -500
