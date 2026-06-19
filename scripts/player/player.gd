extends CharacterBody2D

@export_subgroup("Nodes")
@export var gravity_component: GravityComponent
@export var input_component: InputComponent
@export var movement_component: MovementComponent
@export var jump_component: JumpComponent

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction: float = input_component.input_horizontal
	gravity_component.handle_gravity(self, delta)
	movement_component.handle_horizontal_movement(self, direction)
	jump_component.handle_jump(self, input_component.get_jump_input(), input_component.get_jump_input_released())
	update_animation(direction)
	move_and_slide()

func update_animation(direction):
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
