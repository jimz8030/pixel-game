extends Node2D

var Player : CharacterBody2D

var PlayerCamDifference : float

@export var DampeningAmount : float

var mouse_bounds : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Player = $"../CharacterBody2D"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	PlayerCamDifference = self.global_position.x - Player.global_position.x
	
	
	var mouse_pos = get_global_mouse_position()
	

	if mouse_pos.x - Player.position.x > 0:
		mouse_bounds = true
	elif mouse_pos.x - Player.position.x < 0:
		mouse_bounds = false
	

	if mouse_bounds: #Player.PlayerSprite.scale.x == -1:
		if PlayerCamDifference > 180:
			self.global_position.x -= abs(PlayerCamDifference - 180) / DampeningAmount
		elif PlayerCamDifference < 130:
			self.global_position.x += abs(PlayerCamDifference - 130) / DampeningAmount

	elif mouse_bounds == false: #Player.PlayerSprite.scale.x == 1:
		if PlayerCamDifference > -130:
			self.global_position.x -= abs(PlayerCamDifference + 130) / DampeningAmount
		elif PlayerCamDifference < -180:
			self.global_position.x += abs(PlayerCamDifference + 180) / DampeningAmount
