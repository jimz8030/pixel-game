class_name NPC
extends CharacterBody2D

@onready
var state_machine = $StateMachine


const SPEED = 50.0
const JUMP_VELOCITY = -400.0

var idle_bound_left: float
var idle_bound_right: float
var pathfind: float
var max_idle_time: float = 15.0
var idle_time: float

func _ready() -> void:
	state_machine.init(self)
	idle_bound_left = self.global_position.x - 100.0
	idle_bound_right = self.global_position.x + 100.0
	pathfind = global_position.x
func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)
func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)
func _process(delta: float) -> void:
	state_machine.process_frame(delta)


#func _physics_process(delta: float) -> void:
#	# Add the gravity.
#	if not is_on_floor():
#		velocity += get_gravity() * delta
#	var direction = 0
#	if pathfind + 10 > self.position.x and self.position.x > pathfind - 10:
#		direction = 0
#	elif self.position.x > pathfind:
#		direction = -1
#	elif self.position.x < pathfind:
#		direction = 1
#
#	if velocity.x == 0:
#		pathfind = make_new_path()
#	
#	# Handle jump.
#	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#		#velocity.y = JUMP_VELOCITY
#	
#	if direction:
#		velocity.x = direction * SPEED
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#
#	move_and_slide()
#
#	
#func make_new_path() -> float:
#	var path = randf_range(idle_bound_left,idle_bound_right)
#	return path
#
#
#func Hit():
#	print("hit")
#
