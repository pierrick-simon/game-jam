class_name JumpComponent
extends Node

@export_subgroup("Nodes")
@export var jump_buffer_timer: Timer
@export var coyote_timer: Timer

@export_subgroup("Settings")
@export var jump_velocity: float = -350.0

var is_going_up: bool = false
var was_dashing: bool = false

var is_jumping: bool = false
var last_frame_on_floor: bool = false

func has_just_landed(body: CharacterBody2D) -> bool:
	return body.is_on_floor() and not last_frame_on_floor and is_jumping

func handle_jump(body: CharacterBody2D, want_to_jump: bool, is_dashing: bool) -> void:
	if has_just_landed(body):
		is_jumping = false
	if is_dashing:
		body.velocity.y = 0
	if want_to_jump and (body.is_on_floor() or not coyote_timer.is_stopped()) and not is_dashing:
		jump(body)
	
	handle_coyote_time(body)
	handle_jump_buffer(body, want_to_jump, is_dashing, was_dashing)
	
	is_going_up = body.velocity.y < 0 and not body.is_on_floor()
	was_dashing = is_dashing
	last_frame_on_floor = body.is_on_floor()

func handle_jump_buffer(body: CharacterBody2D, want_to_jump: bool, is_dashing: bool, was_dashing: bool) -> void:
	if want_to_jump and not body.is_on_floor():
		if is_dashing:
			jump_buffer_timer.start(jump_buffer_timer.wait_time / 4)
		else:
			jump_buffer_timer.start()
	if (body.is_on_floor() or (not is_dashing and was_dashing)) and not jump_buffer_timer.is_stopped():
		jump(body)

func handle_coyote_time(body: CharacterBody2D) -> void:
	if not body.is_on_floor() and last_frame_on_floor and not is_jumping:
		coyote_timer.start()
	
	if not coyote_timer.is_stopped() and not is_jumping:
		body.velocity.y = 0

func jump(body: CharacterBody2D) -> void:
	body.velocity.y = jump_velocity
	jump_buffer_timer.stop()
	is_jumping = true
	coyote_timer.stop()
