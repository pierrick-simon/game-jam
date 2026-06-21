extends CharacterBody2D


const SPEED = 50.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.play("walk")

func _physics_process(delta: float) -> void:
	velocity.x = SPEED
	move_and_slide()
	if global_position.x > 2000.0:
		queue_free()
