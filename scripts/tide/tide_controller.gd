class_name TideController
extends Node2D

@onready var WAVE: Sprite2D = $Wave

@export var MIN_TIME_TILL_TIDE: float = 0
@export var MAX_TIME_TILL_TIDE: float = 40

@export var y_expression_string: String = "(sin(t*6) * 0.2 + 0.3 * t)/2"
@onready var _y_expression := Expression.new()

var tideTimer := Timer.new()

@export var tideUp: bool = false

var screenSize: Vector2

func _evalute_pos(t: float) -> void:
	position.y = _y_expression.execute([t])

func moveTideUp() -> void:
	var tween := create_tween()
	tween.tween_method(_evalute_pos, 0, screenSize.y, 5)
	tideUp = true

func moveTideDown() -> void:
	print("Moving down")
	tideUp = false

func getNewTideTime() -> float:
	return randf_range(MIN_TIME_TILL_TIDE, MAX_TIME_TILL_TIDE)
	
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

	WAVE.position.y = 0.0 if tideUp else get_viewport().get_visible_rect().size.y + (-WAVE.offset.y) * WAVE.scale.y
