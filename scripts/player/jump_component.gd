class_name JumpComponent
extends Node

@export_subgroup("Nodes")
@export var jump_buffer_timer: Timer

@export_subgroup("Settings")
@export var jump_velocity: float = -350.0

var is_going_up: bool = false;

func handle_jump(body: CharacterBody2D, want_to_jump: bool) -> void:

	if want_to_jump and body.is_on_floor():
		jump(body)
	
	handle_jump_buffer(body, want_to_jump)
	
	is_going_up = body.velocity.y < 0 and not body.is_on_floor()

func handle_jump_buffer(body: CharacterBody2D, want_to_jump: bool) -> void:
	if want_to_jump and not body.is_on_floor():
		jump_buffer_timer.start()
	if body.is_on_floor() and not jump_buffer_timer.is_stopped():
		jump(body)

func jump(body: CharacterBody2D) -> void:
	body.velocity.y = jump_velocity
	jump_buffer_timer.stop()
