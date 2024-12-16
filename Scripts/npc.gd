extends CharacterBody2D
class_name NPC


@onready
var state_machine = $StateMachine


const SPEED = 50.0
const JUMP_VELOCITY = -400.0

var idle_bound_left: float
var idle_bound_right: float
var pathfind: float
var max_idle_time: float = 15.0
var idle_time: float

@export var health: float = 10.0



func take_damage(amount: int) -> void:
	health -= amount
	print (health)
	if health <= 0:
		queue_free()


#flips the NPC around along with their sight and other nodes
func flip_left() -> void:
	get_node("Sprite2D").scale.x = 1
	get_node("SightArea2D/CollisionShape2D").position.x = -27
func flip_right() -> void:
	get_node("Sprite2D").scale.x = -1
	#scale.x = 1
	get_node("SightArea2D/CollisionShape2D").position.x = 27

func _ready() -> void:
	print(self)
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


#func _body_entered_sight(body: Node2D) -> void:
	#pass #the following commented code mades the npc crouch when you crouch, maybe have a system that puts you ontop of their head when you crouch and press interact
	#if body.has_node("CharacterCollision"):
		#var body_collision: =  body.get_node("CharacterCollision")
		#if body_collision.scale.y == .5:
			#print("scale is checked right")
			#var npc_collision = get_node("NPCCollision")
			#npc_collision.scale.y = .25
			#npc_collision.position.y = -10
			#self.position.y = 60
			
