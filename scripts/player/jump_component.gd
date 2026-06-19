class_name JumpComponent
extends Node

@export_subgroup("Nodes")
@export var jump_buffer_timer: Timer

@export_subgroup("Settings")
@export var jump_velocity: float = -350.0

var is_going_up: bool = false
var was_dashing: bool = false

func handle_jump(body: CharacterBody2D, want_to_jump: bool, is_dashing: bool) -> void:
	if is_dashing:
		body.velocity.y = 0
	if want_to_jump and body.is_on_floor() and not is_dashing:
		jump(body)
	
	handle_jump_buffer(body, want_to_jump, is_dashing, was_dashing)
	
	is_going_up = body.velocity.y < 0 and not body.is_on_floor()
	was_dashing = is_dashing

func handle_jump_buffer(body: CharacterBody2D, want_to_jump: bool, is_dashing: bool, was_dashing: bool) -> void:
	if want_to_jump and not body.is_on_floor():
		if is_dashing:
			jump_buffer_timer.start(jump_buffer_timer.wait_time / 6)
		else:
			jump_buffer_timer.start()
	if (body.is_on_floor() or (not is_dashing and was_dashing)) and not jump_buffer_timer.is_stopped():
		jump(body)

func jump(body: CharacterBody2D) -> void:
	body.velocity.y = jump_velocity
	jump_buffer_timer.stop()
