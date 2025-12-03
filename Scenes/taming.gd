extends Node2D

func _ready() -> void:
	var temp_animal_scene = load(Global_Variables.taming_selection).instantiate()
	self.add_child(temp_animal_scene)
	$CanvasLayer/Animal.texture = temp_animal_scene.get_child(1).texture
	temp_animal_scene.queue_free()
	Global_Variables.taming_selection = ""
	$"CanvasLayer/Taming Bar".value = Global_Variables.taming_strength
	$AnimationPlayer.play("Step 1")

func taming_initial_pull():
	$CanvasLayer/Tug_Rope.value -= randi_range(1,3)
	$AnimationPlayer.play("Step 2")

func taming_apply():
	$CanvasLayer/Tug_Rope.value += $"CanvasLayer/Taming Bar".value
	$"CanvasLayer/Taming Bar".value = 0
	$AnimationPlayer.play("Step 3")

func taming_results():
	if $CanvasLayer/Tug_Rope.value >= 5:
		$RESULTS.text = "TAMED"
		Global_Variables.food_chain_xp += 25
		Global_Variables.reward_xp += 16
	else:
		$RESULTS.text = "WILD"
		Global_Variables.food_chain_xp -= 18
	$AnimationPlayer.play("Step 4")

func taming_exit():
	get_tree().change_scene_to_file("res://Scenes/Paradise.tscn")
