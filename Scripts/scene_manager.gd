extends Node2D

func _on_try_again_loser_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Paradise.tscn")
