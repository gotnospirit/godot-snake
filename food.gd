extends Sprite

var rng:RandomNumberGenerator = RandomNumberGenerator.new()
var pos:Vector2 = Vector2.ZERO

func spawn(snake_cells:Array, world:Vector2, unit_size:int) -> void:
	var free_cells:Array = []

	for x in world.x:
		for y in world.y:
			var cell:Vector2 = Vector2(x, y)

			if snake_cells.find(cell) == -1:
				free_cells.push_back(cell)

	rng.randomize()
	var idx:int = rng.randi_range(0, free_cells.size() - 1)

	pos = free_cells[idx]
#	print("food: ", pos)
	position = free_cells[idx] * unit_size
