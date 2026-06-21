class_name TideController
extends Node2D

@export_subgroup("Basic tide settings")
@export var tide_up: bool = false
@export var is_random: bool = true
@export var underwater_background: Sprite2D

@export_subgroup("Random tide settings")
@export var min_time_between_tide: float = 10.0
@export var max_time_between_tide: float = 15.0
@export var tide_duration: float = 10.0

@export_subgroup("Wave movement expressions")
@export var y_expression_string: String = "(sin(t * 4) * 0.1 + 0.3 * t) / 2.7"
@onready var _y_expression := Expression.new()

@export var x_expression_string: String = "sin(t * 2) * 20"
@onready var _x_expression := Expression.new()

@onready var wave: Sprite2D = $Wave

var _tide_timer := Timer.new()

var _screen_size: Vector2

signal tide_going_up

signal tide_going_down

func switchTide() -> void:
	_tide_timer.start(_getNewTideDelay())
	if !is_random:
		return
	if tide_up:
		moveTideDown()
	else:
		moveTideUp()

func moveTideUp() -> void:
	tide_going_up.emit()
	var tween := create_tween()
	tween.tween_method(_evaluate_pose, 0.0, 10.0, tide_duration)
	tide_up = true

func moveTideDown() -> void:
	tide_going_down.emit()
	var tween := create_tween()
	tween.tween_method(_evaluate_pose, 10.0, 0.0, tide_duration)
	tide_up = false

func get_underwater_y_pos() -> float:
	return wave.global_position.y
	
func _evaluate_pose(t: float) -> void:
	var result_y: float = -_y_expression.execute([t])
	position.y = result_y * _screen_size.y
	var result_x: float = _x_expression.execute([t])
	position.x = result_x
	tide_up = false

func _getNewTideDelay() -> float:
	return tide_duration + randf_range(min_time_between_tide, max_time_between_tide)
	
func _update_screen_size() -> void:
	_screen_size = get_viewport().get_visible_rect().size

func _ready() -> void:
	_update_screen_size()
	get_viewport().size_changed.connect(_update_screen_size)
	
	add_child(_tide_timer)
	_tide_timer.timeout.connect(switchTide)
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

	mat.set_shader_parameter(&"mask_texture", wave.texture)

	mat.set_shader_parameter(&"mask_position", wave.global_position)
	mat.set_shader_parameter(&"mask_size", wave.texture.get_size() * wave.scale)

	mat.set_shader_parameter(&"screen_size", _screen_size)
