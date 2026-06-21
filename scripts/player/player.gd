extends CharacterBody2D

@export_subgroup("Nodes")
@export var gravity_component: GravityComponent
@export var input_component: InputComponent
@export var movement_component: MovementComponent
@export var jump_component: JumpComponent
@export var dash_component: DashComponent

@export_subgroup("Settings")
@export var velocity_max_air: float = 100
@export var velocity_max_water: float = 50
@export var underwater_resistance: float = 300

@onready var animated_sprite = $AnimatedSprite2D

var spawn_point: Vector2

@onready var tide_controller: TideController = %TideController

var finished: bool = false
var can_start: bool = false

func _ready() -> void:
	animated_sprite.play("idle")
	spawn_point = position

func _physics_process(delta: float) -> void:
	if not can_start:
		return
	var direction: float = input_component.input_horizontal
	if not finished:
		dash_component.handle_dash(self, input_component.get_dash_input(), direction)
		movement_component.handle_horizontal_movement(self, direction)
		jump_component.handle_jump(self, input_component.get_jump_input(), dash_component.is_dashing(), is_fully_underwater())
	else:
		velocity.x = velocity.x / 1.5
	gravity_component.handle_gravity(self, delta, dash_component.is_dashing())
	_handle_resistance(self, get_underwater_percentage(), delta)
	update_animation(velocity.x, dash_component.is_dashing())
	move_and_slide()

func _handle_resistance(body: CharacterBody2D, underwater_pourcentage: float, delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y -= sign(body.velocity.y) * underwater_resistance * underwater_pourcentage * delta
		var y_max: float = (velocity_max_air - velocity_max_water) * (1 - underwater_pourcentage) + velocity_max_water
		if body.velocity.y > y_max:
			body.velocity.y = y_max
		print(body.velocity.y)

func update_animation(direction: float, is_dashing: bool):
	if direction > 0:
		animated_sprite.flip_h = false;
	else:
		animated_sprite.flip_h = true;
	if finished and abs(velocity.x) < .1:
		animated_sprite.play("idle")
	if is_dashing:
		animated_sprite.flip_h = not animated_sprite.flip_h
		animated_sprite.play("dash")
		return
	if is_on_floor():
		if direction != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")
	else:
		animated_sprite.play("jump")

func _on_end_npc_has_entered_finish() -> void:
	finished = true

func _on_level_1_can_start() -> void:
	can_start = true
	
func take_damage() -> void:
	if not can_start:
		return
	can_start = false
	velocity = Vector2.ZERO
	global_position = spawn_point
	await get_tree().create_timer(0.3).timeout
	can_start = true

func is_touching_water() -> bool:
	var sprite_y_size = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, 0).get_size().y
	return animated_sprite.global_position.y + sprite_y_size > tide_controller.get_underwater_y_pos()

func is_fully_underwater() -> bool:
	return animated_sprite.global_position.y > tide_controller.get_underwater_y_pos()

func get_underwater_percentage() -> float:
	var underwater_y_pos := tide_controller.get_underwater_y_pos()
	var player_bottom: float = animated_sprite.global_position.y
	var sprite_height = animated_sprite.sprite_frames.get_frame_texture(animated_sprite.animation, 0).get_size().y
	var player_top: float = player_bottom + sprite_height
	return clampf(inverse_lerp(player_top, player_bottom, underwater_y_pos), 0, 1)
