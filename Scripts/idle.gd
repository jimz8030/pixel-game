extends State

#class_name State
@export
var wander_state: State

func enter() -> void:
	super() #used to play the animation from the class
	parent.velocity.x = 0
	parent.pathfind = randf_range(parent.idle_bound_left,parent.idle_bound_right)
	print(parent.pathfind)
	parent.idle_time = parent.max_idle_time
func exit() -> void:
	pass
func process_input(_event: InputEvent) -> State:
	return null
func process_frame(_delta: float) -> State:
	return null
func process_physics(_delta: float) -> State:
	if parent.idle_time <= 0:
		return wander_state
	else:
		parent.idle_time -= .125
	return null
