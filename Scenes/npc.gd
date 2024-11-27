extends CharacterBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -400.0

var idle_bound_left: int
var idle_bound_right: int
var pathfind: float

func _ready() -> void:
	idle_bound_left = self.global_position.x - 100
	idle_bound_right = self.global_position.x + 100


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	var direction = 0
	if pathfind + 10 > self.position.x and self.position.x > pathfind - 10:
		direction = 0
	elif self.position.x > pathfind:
		direction = -1
	elif self.position.x < pathfind:
		direction = 1

	if velocity.x == 0:
		pathfind = make_new_path()
	
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	
func make_new_path() -> float:
	var path = randf_range(idle_bound_left,idle_bound_right)
	return path


func Hit():
	print("hit")
