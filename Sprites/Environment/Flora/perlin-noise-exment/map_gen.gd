extends TileMapLayer

#gets a new noise texture
var noise = FastNoiseLite.new()

#determines where top surface is drawn
var sky_height : int = 60

#gives player option to change seed and map size
@export var total_map_height: int = 150
@export var map_length: int = 600
@export var hill_heights: float = 5.0
@export var cave_size: float = 2.0
@export var cave_amount: float = 20.0
@export var noise_seed : int = 0

@export var go_time : bool = false

#information for terrain sets
var source_id = 4
var snow_tiles_arr = []
var snow_terrain_int = 0
var stone_tiles_arr = []
var stone_terrain_int = 1

#used later when making caves
var hole_noise = FastNoiseLite.new()

func _ready() -> void:
	
	#makes its own seed if the seed is 0 or not set
	if noise_seed == 0:
		noise_seed = RandomNumberGenerator.new().randf_range(0, 100)
		noise.seed = noise_seed
		
	create_snow()
	
	create_stone()
	
	create_caves()

func create_snow():
	
	#defines type of noise and sets the seed to the noise
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	#finds depth of snow based on total map height
	var snow_depth : int = total_map_height / 1.5
	#bottom loop draws top layer, top loop fills in area
	for f in snow_depth:
		for s in map_length:
			var snow_place_x = s
			var snow_noise = noise.get_noise_2d(1, s)
			var snow_place_y = snow_noise * hill_heights * 5 + sky_height + f
			var snow_pos = Vector2i(snow_place_x, snow_place_y)
		
			#applies the cells according to the numbers
			if go_time == true:
				snow_tiles_arr.append(Vector2i(snow_place_x, snow_place_y))
				self.set_cells_terrain_connect(snow_tiles_arr, snow_terrain_int, 0)
			else:
				self.set_cell(Vector2i(snow_place_x, snow_place_y), 4, Vector2i(9,2))

func create_stone():
	
	#defines type of noise and sets the seed to the noise
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	#bottom loop draws top layer, top loop fills in area
	for stone_fill in total_map_height:
		for stone_line in map_length:
			
			var stone_place_x = stone_line
			var stone_noise = noise.get_noise_2d(1, stone_line)
			var stone_place_y = stone_noise * hill_heights + sky_height + 20 + stone_fill
		
			#applies the cells according to the numbers
			if go_time == true:
				stone_tiles_arr.append(Vector2i(stone_place_x, stone_place_y))
				self.set_cells_terrain_connect(stone_tiles_arr, stone_terrain_int, 0)
			else:
				self.set_cell(Vector2i(stone_place_x, stone_place_y), 4, Vector2i(21,2))

func create_caves():
	
	#defines type of noise and sets the seed to the noise
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	hole_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	hole_noise.fractal_octaves = 1.0
	cave_size = (10 - cave_size) / 10
	hole_noise.frequency = cave_amount / 1000
	
	for c in map_length:
		for h in total_map_height + 40:
			var cave_noise = hole_noise.get_noise_2d(c, h)
			if cave_noise > cave_size:
				set_cell(Vector2i(c, h + sky_height - 10), -1)
			else:
				pass
