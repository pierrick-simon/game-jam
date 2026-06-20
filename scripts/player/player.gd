extends CharacterBody2D

@export_subgroup("Nodes")
@export var gravity_component: GravityComponent
@export var input_component: InputComponent
@export var movement_component: MovementComponent
@export var jump_component: JumpComponent
@export var dash_component: DashComponent

@onready var animated_sprite = $AnimatedSprite2D

var finished: bool = false

func _physics_process(delta: float) -> void:
	var direction: float = input_component.input_horizontal
	if not finished:
		dash_component.handle_dash(self, input_component.get_dash_input(), direction)
		movement_component.handle_horizontal_movement(self, direction)
		jump_component.handle_jump(self, input_component.get_jump_input(), dash_component.is_dashing())
	else:
		velocity.x = velocity.x / 1.5
	gravity_component.handle_gravity(self, delta, dash_component.is_dashing())
	update_animation(velocity.x, dash_component.is_dashing())
	move_and_slide()

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
