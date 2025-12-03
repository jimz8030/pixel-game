extends Node2D

var next_to_pickup : bool
var animal_being_tamed : CharacterBody2D

func _ready() -> void:
	$"CanvasLayer2/Tame Menu".process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$AnimationPlayer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	if Global_Variables.player_planetoid_pos != Vector2(0,0):
		$PlayerBody.position = Global_Variables.player_planetoid_pos
	
	if !Global_Variables.player_inv.is_empty():
		var count : int = 0
		for item in Global_Variables.player_inv:
			get_node("PlayerBody/ItemFrame/Slots/Slot_" + str(count)).add_child(load(Global_Variables.player_inv[count]).instantiate())
			get_node("PlayerBody/ItemFrame/Slots/Slot_" + str(count)).get_child(1).position = Vector2(0,0)
			get_node("PlayerBody/ItemFrame/Slots/Slot_" + str(count)).get_child(1).freeze = true
			get_node("PlayerBody/ItemFrame/Slots/Slot_" + str(count)).get_child(1).collision_layer = 8
			get_node("PlayerBody/ItemFrame/Slots/Slot_" + str(count)).get_child(1).collision_mask = 8
			count += 1
			if count == 4:
				break
	
	if Global_Variables.time_limit == 30:
		$CanvasLayer2/Time_Report.visible = false
	else:
		$Death_Timer.wait_time = Global_Variables.time_limit * 60
		$CanvasLayer2/Time_Report.visible = true
		$Death_Timer.start()
		
		Global_Variables.crab_killed = 0
		Global_Variables.ottle_killed = 0

func _process(_delta: float) -> void:
	$"CanvasLayer2/Time_Report/Time Amount".text = str(roundi($Death_Timer.time_left)) + " SEC"

	if next_to_pickup and Global_Variables.time_limit != 30:
		$"Area Pickup/Label2".text = "EXTRACTION IN " + str(roundi($Death_Timer.time_left))
	elif next_to_pickup:
		$"Area Pickup/Label2".text = "PRESS F TO EXTRACT"
		if next_to_pickup and Input.is_action_just_pressed("Store"):
			get_tree().change_scene_to_file("res://Scenes/Mission_Station.tscn")

	$PlayerBody/Extraction_Arrow.look_at($"Area Pickup".position)
	if Input.is_action_just_pressed("Inventory"):
		if $PlayerBody/Extraction_Arrow.visible == true:
			$PlayerBody/Extraction_Arrow.visible = false
		else:
			$PlayerBody/Extraction_Arrow.visible = true

func _on_death_timer_timeout() -> void:
	if next_to_pickup:
		get_tree().change_scene_to_file("res://Scenes/Mission_Station.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Death_Screen.tscn")

#Pickup Area
func _on_drop_pod_body_entered(_body: Node2D) -> void:
	next_to_pickup = true
	$"Area Pickup/Label2".visible = true
func _on_drop_pod_body_exited(_body: Node2D) -> void:
	next_to_pickup = false
	$"Area Pickup/Label2".visible = false

#TAMING
func _on_tame_pressed() -> void:
	$"CanvasLayer2/Tame Menu/Taming Bar".value = $"PlayerBody/Taming Bar".value
	$"CanvasLayer2/Tame Menu".visible = true
	$"CanvasLayer2/Tame Menu/Exit".visible = false
	$CanvasLayer2/Tame.visible = false
	get_tree().paused = true
	$AnimationPlayer.play("Step 1")
func _on_exit_pressed() -> void:
	get_tree().paused = false
	$"CanvasLayer2/Tame Menu".visible = false
	if $"CanvasLayer2/Tame Menu/RESULTS".text == "TAMED":
		animal_being_tamed.queue_free()
	$"PlayerBody/Taming Bar".value = 0
	$"CanvasLayer2/Tame Menu/Tug_Rope".value = 5
	$"CanvasLayer2/Tame Menu/RESULTS".text = ""
func taming_initial_pull():
	$"CanvasLayer2/Tame Menu/Tug_Rope".value -= randi_range(1,3)
	$AnimationPlayer.play("Step 2")
func taming_apply():
	$"CanvasLayer2/Tame Menu/Tug_Rope".value += $"CanvasLayer2/Tame Menu/Taming Bar".value
	$"CanvasLayer2/Tame Menu/Taming Bar".value = 0
	$AnimationPlayer.play("Step 3")
func taming_results():
	if $"CanvasLayer2/Tame Menu/Tug_Rope".value >= 5:
		$"CanvasLayer2/Tame Menu/RESULTS".text = "TAMED"
		Global_Variables.food_chain_xp += 25
		Global_Variables.reward_xp += 16
	else:
		$"CanvasLayer2/Tame Menu/RESULTS".text = "WILD"
		Global_Variables.food_chain_xp -= 18
	$"CanvasLayer2/Tame Menu/Exit".visible = true
