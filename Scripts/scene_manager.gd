extends Node2D

func _ready() -> void:
	Global_Variables.ottle_killed = 0
	Global_Variables.crab_killed = 0

func _on_try_again_loser_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Ship.tscn")
