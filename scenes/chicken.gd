extends CharacterBody2D


const SPEED = 50.0

@export var chicken: AnimatedSprite2D
@export var bald: AnimatedSprite2D

var tide_controller: TideController = null

func _ready() -> void:
	if randf() < 0.3:
		bald.play("walk")
		bald.visible = true
		chicken.visible = false
	else:
		chicken.play("walk")
		
func _get_water_y() -> float:
	return tide_controller.get_underwater_y_pos()

func _physics_process(delta: float) -> void:
	if _get_water_y() < global_position.y:
		_die()

	velocity.x = SPEED
	move_and_slide()
	if global_position.x > 2000.0:
		queue_free()
		
func _die() -> void:
	set_physics_process(false)
	queue_free()
