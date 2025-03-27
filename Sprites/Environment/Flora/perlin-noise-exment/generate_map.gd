extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	
	for x in range (30):
		for y in range (30):
			if noise.get_noise_2d(x,y) < -0.6:
				var sprite = $"TileMap Test_1 (Fail)/Sprite_0".duplicate()
				sprite.position = Vector2(x * sprite.texture.get_size().x, y * sprite.texture.get_size().y) * sprite.scale.x
				add_child(sprite)
			else:
				var sprite = $"TileMap Test_1 (Fail)/Sprite_1".duplicate()
				sprite.position = Vector2(x * sprite.texture.get_size().x, y * sprite.texture.get_size().y) * sprite.scale.x
				add_child(sprite)
