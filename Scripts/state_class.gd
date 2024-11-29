extends Node
class_name State

#info like gravity and other variables that are consistent go here
var parent: NPC

func enter() -> void:
	pass
func exit() -> void:
	pass
func process_input(_event: InputEvent) -> State:
	return null
func process_frame(_delta: float) -> State:
	return null
func process_physics(_delta: float) -> State:
	return null
