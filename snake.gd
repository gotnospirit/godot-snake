extends Node2D

var pos:Vector2 = Vector2.ZERO
var length:int = 4
var speed:float = 1.0
var boundaries:Vector2 = Vector2.ZERO
var unit_size:int = 1
var dir:Vector2 = Vector2.ZERO
var update_time:float = 0.0
var update_delay:float = 0.4

onready var Head:Sprite = $Head

signal dead
signal moved

func setup(start_pos:Vector2, start_length:int, b:Vector2, us:int) -> void:
	pos = start_pos
	length = start_length
	boundaries = b
	unit_size = us

	while get_child_count() > 1:
		var last_child:Sprite = get_child(get_child_count() - 1)
		last_child.queue_free()
		remove_child(last_child)

	while get_child_count() < length:
		_grow().position = Vector2(-us, -us)

	Head.position = start_pos * us
	Head.modulate.a = 1
	Head.z_index = 1

func start() -> void:
	set_process(true)
	set_process_input(true)
	dir = Vector2.RIGHT

func stop() -> void:
	set_process(false)
	set_process_input(false)

func get_cells() -> Array:
	var ret:Array = []
	for c in get_children():
		ret.push_back(c.position / unit_size)
	return ret

func grow() -> void:
	var last_child:Sprite = get_child(get_child_count() - 1)
	_grow().position = last_child.position
	length += 1

func _ready() -> void:
	stop()

func _input(event: InputEvent) -> void:
	var i:int = 0

	if Utils.IsMobile():
		if event is InputEventScreenTouch and not event.is_pressed():
			var cell = event.position / unit_size
			if cell.x > boundaries.x / 2:
				i = 1
			else:
				i = -1
	else:
		i = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if (i == 0):
		return

	match dir:
		Vector2.RIGHT:
			dir = Vector2.DOWN
		Vector2.LEFT:
			dir = Vector2.UP
		Vector2.UP:
			dir = Vector2.RIGHT
		Vector2.DOWN:
			dir = Vector2.LEFT

	dir *= i

	# force update if necessary
	if update_time < update_delay:
		update_time += update_delay - update_time

func _process(delta: float) -> void:
	update_time += delta

	if update_time >= update_delay:
		update_time -= update_delay

		# new head position
		pos += dir
#		print("head: ", pos)

		if _is_deadly_move():
			for child in get_children():
				child.modulate.a = .4
			emit_signal("dead", length)
		else:
			# move tail cells, starting from the end, to next sibling
			for current in range(length - 1, 0, -1):
				get_child(current).position = get_child(current - 1).position
			# move head to new position
			Head.position = pos * unit_size
			emit_signal("moved", pos)

func _grow() -> Sprite:
	var n:Sprite = Head.duplicate()
	n.z_index = 0
	n.modulate = Color.white
	add_child(n)
	return n

func _is_deadly_move() -> bool:
	# out of bounds?
	if pos.x < 0 or pos.x >= boundaries.x or pos.y < 0 or pos.y >= boundaries.y:
		return true

	# collides with tail?
	var tmp:Vector2 = pos * unit_size
	for c in get_children():
		if c != Head and tmp == c.position:
			return true
	return false
