extends Node

@onready var player : CharacterBody2D = $"../PlayerBody"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.position = player.position
