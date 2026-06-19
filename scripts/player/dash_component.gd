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
	if dash_pressed and dash_timer.is_stopped() and dash_cooldown.is_stopped():
		dash_timer.start()
		dash_direction = direction if direction else 1

	if timeout:
		collision_normal.disabled = false
		collision_dash.disabled = true
		body.velocity.x /= 3.5
		dash_cooldown.start()
		timeout = false

	if dash_timer.time_left != 0:
		collision_normal.disabled = true
		collision_dash.disabled = false
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
