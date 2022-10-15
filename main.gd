extends Node2D

const UnitSize:int = 64
const NewGameMsg:String = "Press [space] to start a new game"
const MobileNewGameMsg:String = "Tap to start a new game"
const VictoryMsg:String = "Victory \\(^o^)/\n%s"
const GameOverMsg:String = "Game Over (T_T)\n%s"
const MsgFont = preload("res://font.tres")

var world:Vector2 = Vector2.ZERO
var score:int = 0
var was_dragging:bool = false

onready var Snake:Node2D = $Snake
onready var Food:Sprite = $Food
onready var Score:Label = $Score/Label
onready var Msg:Label = $Message/Label
onready var Screen:Vector2 = get_viewport_rect().size

func _enter_tree() -> void:
	if Utils.IsMobile():
#		print("scale: ", Utils.GetScale())
		MsgFont.size *= Utils.GetScale()

func _ready() -> void:
	world = Screen / UnitSize
#	print("world: ", world)
#	print("screen: ", Screen)

	Snake.connect("moved", self, "_on_snake_moved")
	Snake.connect("dead", self, "_on_snake_dead")

	# start message
	_show_message(0)

	set_process_input(true)

func new_game() -> void:
	set_process_input(false)
	Msg.hide()

	Snake.setup(Vector2.ZERO, 1, world, UnitSize)
	Snake.start()

	Food.spawn(Snake.get_cells(), world, UnitSize)
	_set_score(0)

func _input(event: InputEvent) -> void:
	if Utils.IsMobile():
		if event is InputEventScreenDrag:
			was_dragging = true
			return

		if event is InputEventScreenTouch:
			if not was_dragging and not event.is_pressed():
				new_game()
			was_dragging = false
	elif Input.is_action_just_released("ui_select"):
		new_game()

func _on_snake_moved(pos:Vector2):
	if pos == Food.pos:
		Snake.grow()
		Food.spawn(Snake.get_cells(), world, UnitSize)
		_set_score(score + 1)

func _on_snake_dead(length:int) -> void:
	Snake.stop()

	if length == world.x * world.y:
		# victory
		_show_message(1)
	else:
		# game over
		_show_message(2)

	set_process_input(true)

func _set_score(value:int) -> void:
	score = value
	Score.text = "Score: %d" % [value]

func _show_message(n:int) -> void:
	var start_msg:String = NewGameMsg if not Utils.IsMobile() else MobileNewGameMsg
	match n:
		0:
			_set_message(start_msg)
		1:
			_set_message(VictoryMsg % [start_msg])
		2:
			_set_message(GameOverMsg % [start_msg])

func _set_message(msg:String) -> void:
	var txt_size:Vector2 = _get_text_size(msg)

	Msg.rect_position = (Screen - txt_size) / 2
	Msg.text = msg
	Msg.show()

func _get_text_size(txt:String) -> Vector2:
	var fnt:Font = Msg.get_font("font")
	var ret:Vector2 = Vector2.ZERO

	for line in txt.split("\n"):
		var tmp:Vector2 = fnt.get_string_size(line)
		ret.x = max(ret.x, tmp.x)
		ret.y += tmp.y

	return ret
