extends TileMap

var noise = FastNoiseLite.new()
var map_width = 100
var map_height = 50

# The ID of your tileset source (usually 0 if you only loaded one image)
var source_id = 0 
# The grid coordinates of the specific tile in your tileset image
var atlas_coord = Vector2i(0, 0) 

func _ready():
	# Scramble the seed so it's a new map every time
	noise.seed = randi()
	# This controls how "zoomed in" the shapes are. Tweak this!
	noise.frequency = 0.05 
	
	generate_level()

func generate_level():
	for x in range(map_width):
		for y in range(map_height):
			# Get a noise value between -1.0 and 1.0 for this specific grid spot
			var noise_val = noise.get_noise_2d(x, y)
			
			# If the noise is above 0.0, place a tile. If below, leave it empty.
			if noise_val > 0.0:
				# Layer 0, Grid Position, Tileset ID, Atlas Position
				set_cell(0, Vector2i(x, y), source_id, atlas_coord)
