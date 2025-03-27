extends Node2D

#makes noise texture
@export var perlin_noise = FastNoiseLite.new()
#float that will be be applied to determine intensity later
@export var amplitude : float = 5.0
#Float that will be applied to determine how fast the image moves
@export var speed : float = 0.2

@export var perlin_y_value : float

#
var time : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#makes the amplitude more extreme
	amplitude *= 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#
	time += speed
	var perlin_value = perlin_noise.get_noise_2d(time, perlin_y_value)
	#applies amplitude
	self.position.y = perlin_value * amplitude
