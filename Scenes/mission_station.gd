extends Node2D

@export var food_chain_boxes : Array [Node2D]
@export var mission_description : Array [String]

func _ready() -> void:
	if Global_Variables.active_mission == 0 and Global_Variables.crab_killed >= 2:
		Global_Variables.reward_xp += 32 + (5 / Global_Variables.time_limit)
		Global_Variables.active_mission += 1
	elif Global_Variables.active_mission == 1 and Global_Variables.ottle_killed >= 2:
		Global_Variables.reward_xp += 32 + (5 / Global_Variables.time_limit)
		Global_Variables.active_mission += 1
	elif Global_Variables.active_mission == 2 and Global_Variables.crab_killed >= 3:
		Global_Variables.reward_xp += 32 + (5 / Global_Variables.time_limit)
		Global_Variables.active_mission += 1
	elif Global_Variables.active_mission == 3 and Global_Variables.ottle_killed >= 3:
		Global_Variables.reward_xp += 32 + (5 / Global_Variables.time_limit)
		Global_Variables.active_mission += 1

	$CanvasLayer/MissionMenu/Task.text = "MISSION: " + mission_description[Global_Variables.active_mission]
	$"CanvasLayer/Reward Estimate".value = Global_Variables.reward_xp_estimate

	$"CanvasLayer/You Box/Food Chain Progression".value = 0
	$"CanvasLayer/Reward Progression".value = 0
	
	$AnimationPlayer.play("Face")
	var choose_pic = randi_range(1,2)
	if choose_pic == 1:
		$CanvasLayer/Background_Image.texture = load("res://Sprites/UI/Mission Station/Prey_Face.png")
	else:
		$CanvasLayer/Background_Image.texture = load("res://Sprites/UI/Mission Station/Preditor_Face.png")
	$"CanvasLayer/Time_Report/Time Amount".text = str(Global_Variables.time_limit) + " MIN"
	if $"CanvasLayer/You Box/Food Chain Progression".value != Global_Variables.food_chain_xp or $"CanvasLayer/Reward Progression".value != Global_Variables.reward_xp:
		$Raise_Stats.start()

func _on_close_pressed() -> void:
	$CanvasLayer/MissionMenu.visible = false

func _on_exit_pressed() -> void:
	Global_Variables.reward_xp_estimate = $"CanvasLayer/Reward Estimate".value
	get_tree().change_scene_to_file("res://Scenes/Ship.tscn")

func _on_explore_pressed() -> void:
	$CanvasLayer/Time_Report.visible = false
	$CanvasLayer/MissionMenu.visible = false
	$"CanvasLayer/Reward Estimate".value = 0
	$CanvasLayer/Mission_Explore.texture = load("res://Sprites/UI/Mission Station/Explore.png")
	Global_Variables.time_limit = 30

func _on_mission_pressed() -> void:
	$CanvasLayer/Time_Report.visible = true
	$CanvasLayer/MissionMenu.visible = true
	$CanvasLayer/Mission_Explore.texture = load("res://Sprites/UI/Mission Station/Mission.png")

func _on_input_time_text_submitted(_new_text: String) -> void:
	#Check if there are letters
	var is_letter = RegEx.new()
	is_letter.compile("[a-zA-Z]+")
	if is_letter.search($CanvasLayer/MissionMenu/Input_Time.text):
		$CanvasLayer/MissionMenu/Input_Time.text = ""
	elif int($CanvasLayer/MissionMenu/Input_Time.text) > 20:
		$CanvasLayer/MissionMenu/Input_Time.text = ""

	#Submit the time amount
	else:
		Global_Variables.time_limit = float($CanvasLayer/MissionMenu/Input_Time.text)
		$"CanvasLayer/Time_Report/Time Amount".text = $CanvasLayer/MissionMenu/Input_Time.text + " MIN"
		$CanvasLayer/MissionMenu/Input_Time.text = ""
		$CanvasLayer/MissionMenu.visible = false

	$"CanvasLayer/Reward Estimate".value = $"CanvasLayer/Reward Progression".value + (32 + (5 / Global_Variables.time_limit))

func _on_raise_stats_timeout() -> void:
	if $"CanvasLayer/You Box/Food Chain Progression".value != Global_Variables.food_chain_xp or $"CanvasLayer/Reward Progression".value != Global_Variables.reward_xp:
		$Raise_Stats.start()
		$"CanvasLayer/You Box/Food Chain Progression".value += (Global_Variables.food_chain_xp - $"CanvasLayer/You Box/Food Chain Progression".value) / 10
		$"CanvasLayer/Reward Progression".value += (Global_Variables.reward_xp - $"CanvasLayer/Reward Progression".value) / 10

	if $"CanvasLayer/You Box/Food Chain Progression".value >= 95:
		$"CanvasLayer/You Box".position.y -= 31
		Global_Variables.food_chain_xp -= 95
		$"CanvasLayer/You Box/Food Chain Progression".value = 0
		
		var food_chain_pos = food_chain_boxes.find($"CanvasLayer/You Box")
		if food_chain_pos == 3:
			food_chain_boxes.insert(2,$"CanvasLayer/You Box")
			food_chain_boxes.remove_at(4)
			$"CanvasLayer/3 Box".position.y += 31
			
		elif food_chain_pos == 2:
			food_chain_boxes.insert(1,$"CanvasLayer/You Box")
			food_chain_boxes.remove_at(3)
			$"CanvasLayer/2 Box".position.y += 31
		
		elif food_chain_pos == 1:
			food_chain_boxes.insert(0,$"CanvasLayer/You Box")
			food_chain_boxes.remove_at(2)
			$"CanvasLayer/1 Box".position.y += 31
