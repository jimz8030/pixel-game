extends State
@export
var wander_state: State

var gravity = 100

func enter() -> void:
	super() #used to play the animation from the class
func exit() -> void:
	pass
func process_input(_event: InputEvent) -> State:
	return null
func process_frame(_delta: float) -> State:
	return null
func process_physics(_delta: float) -> State:
	parent.velocity.y += gravity * _delta
	parent.move_and_slide()
	if parent.is_on_floor():
		parent.velocity.y = 0
		return wander_state
	return null
