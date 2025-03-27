extends TileMapLayer

@export var iterations : int = 60

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for n in range(iterations):
		self.set_cell(Vector2i(n, 60), 4, Vector2i(9, 2))
