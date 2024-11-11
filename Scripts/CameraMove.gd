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
	

#detects if mouse is to the right of player
	if mouse_bounds: #Player.PlayerSprite.scale.x == -1:
		#detects if player is going far past the bounds in which case the camera speeds up
		if PlayerCamDifference > 200:
			self.global_position.x -= abs(PlayerCamDifference - 200) / (DampeningAmount / 2)
		#detects if the player is going a little bit to the left while mouse is to the right
		elif PlayerCamDifference > 180:
			self.global_position.x -= abs(PlayerCamDifference - 180) / DampeningAmount
		#detects if the player is moving to the left while mouse is to the left of the player
		elif PlayerCamDifference < 130:
			self.global_position.x += abs(PlayerCamDifference - 130) / DampeningAmount

# detects if mous is to the left of player
	elif mouse_bounds == false: #Player.PlayerSprite.scale.x == 1:
		#detects if the player is going left when mouse is to the left of player.
		if PlayerCamDifference > -130:
			self.global_position.x -= abs(PlayerCamDifference + 130) / DampeningAmount
		# detects if the player is going far to the right, in this case the camera speeds up so the player doesn't go off screen 
		#(this needs to be first otherwise the below code would activate and the camera wouldn't speed up)
		elif PlayerCamDifference < -200:
			self.global_position.x += abs(PlayerCamDifference + 200) / (DampeningAmount / 2)
		# detects if the player is going right when mouse is to the left of player. Then adjusts camera speed
		elif PlayerCamDifference < -180:
			self.global_position.x += abs(PlayerCamDifference + 180) / DampeningAmount
