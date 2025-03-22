extends Node

var fruit_num : int = 2
var can_pick : bool = false
var fruit_held : int = 0

@export var fruit_name : String


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if can_pick and Input.is_action_just_pressed("Interact"):
		fruit_held += 1
		#if there are both fruit, one is picked
		if fruit_num == 2:
			var plucked_fruit = choose([1,2])
			get_child(plucked_fruit).visible = false
			$"Regrow Time".start()

		#if there is only one fruit, both are removed and you can't pick anymore
		elif fruit_num == 1:
			get_child(1).visible = false
			get_child(2).visible = false
			can_pick = false
		fruit_num -= 1

func _on_body_entered(body: Node2D) -> void:
	if body.name == "PlayerBody":
		can_pick = true
	#other creatures might eat fruit
	else:
		var pick_chance = choose([1,2,3,4])
		if pick_chance == 4:
			#if there are both fruit, one is picked
			if fruit_num == 2:
				var plucked_fruit = choose([1,2])
				get_child(plucked_fruit).visible = false
				$"Regrow Time".start()
			#if there is only one fruit, both are removed
			elif fruit_num == 1:
				get_child(1).visible = false
				get_child(2).visible = false
			fruit_num -= 1

func choose(array):
	array.shuffle()
	return array.front()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "PlayerBody":
		can_pick = false


func _on_regrow_time_timeout() -> void:
	#both fruits come back after a while
	get_child(1).visible = true
	get_child(2).visible = true
