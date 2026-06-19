class_name DashComponent
extends Node

@export_subgroup("Node")
@export var dash_timer: Timer
@export var dash_cooldown: Timer
@export var collision_normal: CollisionShape2D
@export var collision_dash: CollisionShape2D

@export_subgroup("Settings")
@export var dash_speed: float = 3000.0

var timeout: bool = false
var dash_direction: float

func handle_dash(body: CharacterBody2D, dash_pressed: bool, direction: float):
	if dash_pressed and dash_timer.is_stopped() and dash_cooldown.is_stopped() and (not body.is_on_wall() or sign(body.get_wall_normal().x) == sign(direction)):
		dash_timer.start()
		dash_direction = direction if direction else 1

	if timeout:
		body.velocity.x /= 3.5
		dash_cooldown.start()
		timeout = false

	if dash_timer.time_left == 0:
		if not _is_overlapping_if_enabled(body):
			collision_normal.disabled = false
	if dash_timer.time_left != 0:
		collision_normal.disabled = true
		body.velocity.x = dash_speed if dash_direction > 0 else -dash_speed
		if body.is_on_wall():
			dash_direction = -dash_direction
			body.velocity.x = -body.velocity.x
			_on_dash_timer_timeout()
			dash_timer.stop()

func is_dashing():
	return dash_timer.time_left != 0

func _on_dash_timer_timeout() -> void:
	timeout = true

func _is_overlapping_if_enabled(body: CharacterBody2D) -> bool:
	var space_state = body.get_world_2d().direct_space_state
	var shape = collision_normal.shape
	var transform = body.global_transform * collision_normal.transform
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = transform
	query.collision_mask = body.collision_mask
	query.exclude = [body.get_rid()]
	var results = space_state.intersect_shape(query)
	return results.size() > 0
