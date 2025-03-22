extends Node2D
class_name Item

var cursor_in : bool
var moving_item : bool

var mouse_offset = Vector2(0,0)

func _ready() -> void:
	$RigidBody2D.freeze = false

func _process(delta: float) -> void:
	#DRAGGING ITEM
	if cursor_in == true and Input.is_action_pressed("Left_Click"):
		$RigidBody2D.rotation = 0
		$RigidBody2D.freeze = true
		moving_item = true
	elif Input.is_action_just_released("Left_Click"):
		moving_item = false
		$RigidBody2D.freeze = false
	if moving_item:
		var cursor_pos = get_canvas_transform().affine_inverse() * get_global_mouse_position()
		position = cursor_pos


func _on_rigid_body_2d_mouse_entered() -> void:
	cursor_in = true
