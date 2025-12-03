extends Node2D

var next_to_customize : bool
var next_to_mission : bool
var next_to_drop : bool

func _ready() -> void:
	#Load player inventory
	if !Global_Variables.player_inv.is_empty():
		var count : int = 0
		for item in Global_Variables.player_inv:
			get_node("PlayerBody/ItemFrame/Slots/Slot_" + str(count)).add_child(load(Global_Variables.player_inv[count]).instantiate())
			get_node("PlayerBody/ItemFrame/Slots/Slot_" + str(count)).get_child(1).position = Vector2(0,0)
			get_node("PlayerBody/ItemFrame/Slots/Slot_" + str(count)).get_child(1).freeze = true
			get_node("PlayerBody/ItemFrame/Slots/Slot_" + str(count)).get_child(1).collision_layer = 8
			get_node("PlayerBody/ItemFrame/Slots/Slot_" + str(count)).get_child(1).collision_mask = 8
			count += 1
	
	Global_Variables.player_planetoid_pos = Vector2(0,0)
	
	if Global_Variables.player_ship_pos != null:
		$PlayerBody.position = Global_Variables.player_ship_pos
	if Global_Variables.time_limit == 0:
		Global_Variables.time_limit = 30

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Store"):
		if next_to_customize:
			Global_Variables.player_ship_pos = $PlayerBody.position
			get_tree().change_scene_to_file("res://Scenes/Customization.tscn")
		elif next_to_mission:
			Global_Variables.player_ship_pos = $PlayerBody.position
			get_tree().change_scene_to_file("res://Scenes/Mission_Station.tscn")
		elif next_to_drop:
			Global_Variables.player_ship_pos = $PlayerBody.position
			get_tree().change_scene_to_file("res://Scenes/Paradise.tscn")


#Customization Chamber
func _on_customization_console_body_entered(_body: Node2D) -> void:
	next_to_customize = true
	$"Customization Console/Label2".visible = true
func _on_customization_console_body_exited(_body: Node2D) -> void:
	next_to_customize = false
	$"Customization Console/Label2".visible = false

#Mission Station
func _on_mission_station_body_entered(_body: Node2D) -> void:
	next_to_mission = true
	$"Mission Station/Label2".visible = true
func _on_mission_station_body_exited(_body: Node2D) -> void:
	next_to_mission = false
	$"Mission Station/Label2".visible = false

#Drop Pod
func _on_drop_pod_body_entered(body: Node2D) -> void:
	next_to_drop = true
	$"Drop Pod/Label2".visible = true
func _on_drop_pod_body_exited(body: Node2D) -> void:
	next_to_drop = false
	$"Drop Pod/Label2".visible = false
