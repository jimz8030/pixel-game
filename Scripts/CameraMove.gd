extends Node2D

var PlayerSprite : Node2D

var PlayerCamDifference : float
var YPlayerCamDifference : float

@export var DampeningAmount : float
@export var Player : CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerSprite = $"../CharacterBody2D/Character"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	PlayerCamDifference = self.global_position.x - Player.global_position.x
	YPlayerCamDifference = self.global_position.y - Player.global_position.y

#detects if player is facing right
	if PlayerSprite.scale.x == -1: #Player.PlayerSprite.scale.x == -1:
		#detects if player is going far past the bounds in which case the camera speeds up
		if PlayerCamDifference > 200:
			self.global_position.x -= abs(PlayerCamDifference - 200) / (DampeningAmount / 2)
		#detects if the player is going a little bit to the left while mouse is to the right
		elif PlayerCamDifference > 180:
			self.global_position.x -= abs(PlayerCamDifference - 180) / DampeningAmount
		#detects if the player is moving to the left while mouse is to the left of the player
		elif PlayerCamDifference < 130:
			self.global_position.x += abs(PlayerCamDifference - 130) / DampeningAmount

# detects if player is facing left
	else:
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
	
	#detects if player is above bounds
	if YPlayerCamDifference > 80:
		self.global_position.y -= abs(YPlayerCamDifference) / (DampeningAmount * 2)
	if YPlayerCamDifference > 120:
		self.global_position.y -= abs(YPlayerCamDifference) / (DampeningAmount)
	
	#detects if player is below bounds
	if YPlayerCamDifference < -100:
		self.global_position.y += abs(YPlayerCamDifference) / (DampeningAmount * 2)
	if YPlayerCamDifference < -160:
		self.global_position.y += abs(YPlayerCamDifference) / (DampeningAmount)
