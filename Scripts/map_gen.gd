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

#information for terrain sets
var source_id = 0
var snow_tiles_arr = []
var snow_terrain_int = 0
var stone_tiles_arr = []
var stone_terrain_int = 1

#used later when making caves
var hole_noise = FastNoiseLite.new()

#used to determine which tiles are rendered (x and y total = 125 typically)
@export var camera : Node2D
var cam_bounds_left : int = 45
var cam_bounds_right : int = 80
var cam_bounds_down : int = 1
var cam_bounds_up : int = 1

#Information used to render snow
var countdown : int = 0
var crush_count : int = 0
var snow_run_tile : Vector2i
@onready var Player : CharacterBody2D = $"../../CharacterBody2D"

func _ready() -> void:
	
	#makes its own seed if the seed is 0 or not set
	if noise_seed == 0:
		noise_seed = RandomNumberGenerator.new().randf_range(0, 100)
		noise.seed = noise_seed
	
	#IDEA
	#render stone, then render snow while checking if there is stone alreay in the cell
	#render caves, then render snow and stone while checking if there is cave space alreay in the cell
	#only load what's on the screen, then load more as the camera moves
	#only load where light reaches, reload when light reaches further
	
	#create_stone()
	
	#create_caves()
	
	#defines type of noise and sets the seed to the noise
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	#finds depth of snow based on total map height
	var snow_depth : int = total_map_height
	#bottom loop draws top layer, top loop fills in area
	for f in snow_depth:
		for s in map_length:
			#the x position of the tiles will be 1 + the one before it
			var snow_place_x = s
			#goes through the noise to determine the y position of the tiles
			var snow_noise = noise.get_noise_2d(1, s)
			#applies noise to tile and considers the sky height. repeats the line to fill the area (f)
			var snow_place_y = snow_noise * hill_heights * 5 + sky_height + f
			
			#checks the bounds of the camera and only draws tiles around the camera
			if s < 95 and s > 0 and f >= 1:
				self.set_cell(Vector2i(snow_place_x, snow_place_y), 0, Vector2i(9,2))
			else:
				pass

func create_stone():
	
	#defines type of noise and sets the seed to the noise
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	#bottom loop draws top layer, top loop fills in area
	for stone_fill in total_map_height:
		for stone_line in map_length:
			
			var stone_place_x = stone_line
			var stone_noise = noise.get_noise_2d(1, stone_line)
			var stone_place_y = stone_noise * hill_heights + sky_height + 10 + stone_fill
		
			#applies the cells according to the numbers
			self.set_cell(Vector2i(stone_place_x, stone_place_y), 0, Vector2i(21,2))

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

func _process(delta: float) -> void:
	#counts down to determine how often the snow is renewed
	countdown -= 1
	render_snow()
	if Player.is_on_floor():
		crush_count -= 1
	#resets counter inside function

func render_snow():
	
	#renews top layer of snow when countdown is complete
	if countdown <= 0:
		#finds the bounds of the camera
		cam_bounds_left = (camera.position.x / 10.4166) - 60
		cam_bounds_right = (camera.position.x / 10.4166) + 60
		cam_bounds_up = (camera.position.y / 10.4166) + 25
		cam_bounds_down = (camera.position.y / 10.4166) - 25
		
		#defines the noise
		noise.noise_type = FastNoiseLite.TYPE_PERLIN
		
		#finds depth of snow based on total map height
		var snow_depth : int = total_map_height
		
		#STEP 1: fills in bottom layers of snow
		
		#fills according to determined depth of snow (y position)
		for f in snow_depth:
			#draws line according to length of snow (x position)
			for s in map_length:
				
				#checks camera bounds and skips first layer of snow
				if f < cam_bounds_up and f > cam_bounds_down and s < cam_bounds_right and s > cam_bounds_left and f >= 1:
					
					#the x position of the tiles will be 1 + the one before it
					var snow_place_x = s
					#goes through the noise to determine the y position of the tiles
					var snow_noise = noise.get_noise_2d(1, s)
					#applies noise to tile and considers the sky height. repeats the line to fill the area (f)
					var snow_place_y = snow_noise * hill_heights * 5 + sky_height + f
					
					self.set_cell(Vector2i(snow_place_x, snow_place_y), 0, Vector2i(9,2))
				
				#removes tiles outside camera
				else:
					if f >= 1:
						var snow_place_x = s
						var snow_noise = noise.get_noise_2d(1, s)
						var snow_place_y = snow_noise * hill_heights * 5 + sky_height + f
						
						#erases tile from cell
						self.erase_cell(Vector2i(snow_place_x, snow_place_y))
		
		#STEP 2: renders top layer of snow
		
		#top loop is the 1st layer of snow (y), bottom is the full length of the map (x)
		for f in range(1):
			for s in map_length:
				
				#checks camera bounds
				if s < cam_bounds_right and s > cam_bounds_left:
					
					#tile x position is 1 + the one before it
					var snow_place_x = s
					#looks at noise to randomize y position of tiles
					var snow_noise = noise.get_noise_2d(1, s)
					#applies noise to tile and considers the sky height. repeats the line to fill the area (f)
					var snow_place_y = snow_noise * hill_heights * 5 + sky_height + f
					
					#checks if the cell is empty
					if self.get_cell_atlas_coords(Vector2i(snow_place_x, snow_place_y)) == Vector2i(-1, -1):
						#picks a random "run tile" to place to draw the ground
						var tile_number_1 = RandomNumberGenerator.new().randi_range(9, 10)
						var tile_number_2 = RandomNumberGenerator.new().randi_range(0, 1)
						#this statement is only used to get a random tile
						if tile_number_2 == 1:
							tile_number_2 = 4
						else:
							pass
						
						snow_run_tile = Vector2i(tile_number_1, tile_number_2)
						#applies the random run tile
						self.set_cell(Vector2i(snow_place_x, snow_place_y), 0, snow_run_tile)
					
					#overlooks cells that are already drawn
					else:
						pass
					
				#deletes tiles in cells outside of bounds
				else:
					#gets cell position
					var snow_place_x = s
					var snow_noise = noise.get_noise_2d(1, s)
					var snow_place_y = snow_noise * hill_heights * 5 + sky_height + f
					self.erase_cell(Vector2i(snow_place_x, snow_place_y))
		#countdown resets after function is ran
		countdown = 30
		
		#crushes snow under player's feet
		if Player.is_on_floor():
			crush_count -= 1
		else:
			crush_count = 2
		var crush_cell = Vector2i(Player.position.x / 10.4166, ((Player.position.y / 10.5) + 50))
		if crush_count <= 0 and self.get_cell_atlas_coords(Vector2i(crush_cell)) != Vector2i(-1, -1):
			self.set_cell(crush_cell, 0, Vector2i(10,8))
