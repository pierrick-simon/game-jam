class_name TideController
extends Node2D

@onready var WAVE: Sprite2D = $Wave

@export var MIN_TIME_BETWEEN_TIDE: float = 10
@export var MAX_TIME_BETWEEN_TIDE: float = 15
@export var TIDE_TIME: float = 10

@export var y_expression_string: String = "(sin(t * 4) * 0.1 + 0.3 * t) / 2.7"
@onready var _y_expression := Expression.new()

var tideTimer := Timer.new()

@export var tideUp: bool = false

var screenSize: Vector2

func _evalute_pos(t: float) -> void:
	var result: float = -_y_expression.execute([t])
	position.y = result * screenSize.y

func moveTideUp() -> void:
	print("Going up")
	var tween := create_tween()
	tween.tween_method(_evalute_pos, 0.0, 10.0, TIDE_TIME)
	tideUp = true

func moveTideDown() -> void:
	print("Moving down")
	var tween := create_tween()
	tween.tween_method(_evalute_pos, 10.0, 0.0, TIDE_TIME)
	tideUp = false

func getNewTideTime() -> float:
	return TIDE_TIME + randf_range(MIN_TIME_BETWEEN_TIDE, MAX_TIME_BETWEEN_TIDE)
	
func moveTide() -> void:
	if tideUp:
		moveTideDown()
	else:
		moveTideUp()
	tideTimer.start(getNewTideTime())

func update_screen_size() -> void:
	screenSize = get_viewport().get_visible_rect().size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_screen_size()
	get_viewport().size_changed.connect(update_screen_size)
	
	add_child(tideTimer)
	tideTimer.timeout.connect(moveTide)
	tideTimer.start(getNewTideTime())
	
	var err := _y_expression.parse(y_expression_string, ["t"])

	if err != OK:
		push_error("Invalid expression")

	WAVE.position.y = 0.0 if tideUp else get_viewport().get_visible_rect().size.y
