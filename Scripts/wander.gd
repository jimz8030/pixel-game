extends State
#the wander state
@export
var idle_state: State
@export
var falling_state: State

var idle_bound_left: int
var idle_bound_right: int
var direction: = 0

func enter() -> void:
	super() #used to play the animation from the class
func exit() -> void:
	pass
func process_input(_event: InputEvent) -> State:
	return null
func process_frame(_delta: float) -> State:
	return null
func process_physics(_delta: float) -> State:
	if parent.pathfind + 10 > parent.position.x and parent.position.x > parent.pathfind - 10:
		return idle_state
	elif parent.position.x > parent.pathfind:
		direction = -1
		parent.flip_left()
	elif parent.position.x < parent.pathfind:
		direction = 1
		parent.flip_right()
	if direction:
		parent.velocity.x = direction * parent.SPEED
		parent.move_and_slide()
		if parent.velocity.x == 0:
			return idle_state
			
	if parent.is_on_floor():
		return falling_state
	else:#I think this should be a slowing down state
		parent.velocity.x = move_toward(parent.velocity.x, 0, parent.SPEED)
	return null
