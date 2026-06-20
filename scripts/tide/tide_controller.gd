class_name TideController
extends Node2D

@export_category("Tide controls")
@export var tide_up: bool = false
@export var is_random: bool = true

@export var min_time_between_tide: float = 10
@export var max_time_between_tide: float = 15
@export var tide_duration: float = 10

@export var underwater_background: Sprite2D

@export_category("Wave movement expressions")
@export var y_expression_string: String = "(sin(t * 4) * 0.1 + 0.3 * t) / 2.7"
@onready var _y_expression := Expression.new()

@export var x_expression_string: String = "sin(t * 2) * 20"
@onready var _x_expression := Expression.new()

@onready var wave: Sprite2D = $Wave

var _tide_timer := Timer.new()


var _screen_size: Vector2

func _evalute_pos(t: float) -> void:
	var result_y: float = -_y_expression.execute([t])
	position.y = result_y * _screen_size.y
	var result_x: float = _x_expression.execute([t])
	position.x = result_x

func moveTideUp() -> void:
	print("Going up")
	var tween := create_tween()
	tween.tween_method(_evalute_pos, 0.0, 10.0, tide_duration)
	tide_up = true

func moveTideDown() -> void:
	print("Moving down")
	var tween := create_tween()
	tween.tween_method(_evalute_pos, 10.0, 0.0, tide_duration)
	tide_up = false

func _getNewTideDelay() -> float:
	return tide_duration + randf_range(min_time_between_tide, max_time_between_tide)
	
func moveTide() -> void:
	_tide_timer.start(_getNewTideDelay())
	if !is_random:
		return
	if tide_up:
		moveTideDown()
	else:
		moveTideUp()

func _update_screen_size() -> void:
	_screen_size = get_viewport().get_visible_rect().size

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_screen_size()
	get_viewport().size_changed.connect(_update_screen_size)
	
	add_child(_tide_timer)
	_tide_timer.timeout.connect(moveTide)
	_tide_timer.start(_getNewTideDelay())
	
	var err := _y_expression.parse(y_expression_string, ["t"])
	if err != OK:
		push_error("Invalid y expression")
	
	err = _x_expression.parse(x_expression_string, ["t"])
	if err != OK:
		push_error("Invalid x expression")

	wave.position.y = 0.0 if tide_up else _screen_size.y

func _process(_delta):
	var mat: ShaderMaterial = underwater_background.material as ShaderMaterial

	mat.set_shader_parameter("mask_texture", wave.texture)

	mat.set_shader_parameter("mask_position", wave.global_position)
	mat.set_shader_parameter("mask_size", wave.texture.get_size() * wave.scale)

	mat.set_shader_parameter("screen_size", _screen_size)
