extends Area2D

var can_boost : bool
var dude : Node2D
@export var jump_boost = 500

func _on_body_entered(body: Node2D) -> void:
	can_boost = true
	dude = body

func _on_body_exited(_body: Node2D) -> void:
	can_boost = false
	dude = null
	
func _process(_delta: float) -> void:
	if can_boost and dude.velocity.y < 0:
		dude.velocity.y = -jump_boost
