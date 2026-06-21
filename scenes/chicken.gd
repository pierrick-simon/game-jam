extends CharacterBody2D


const SPEED = 50.0

@export var chicken: AnimatedSprite2D
@export var bald: AnimatedSprite2D

func _ready() -> void:
	if randf() < 0.3:
		bald.play("walk")
		bald.visible = true
		chicken.visible = false
		
	else:
		chicken.play("walk")

func _physics_process(delta: float) -> void:
	velocity.x = SPEED
	move_and_slide()
	if global_position.x > 2000.0:
		queue_free()
