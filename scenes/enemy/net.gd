extends CharacterBody2D

@onready var sprite = $Sprite2D

const SPEED = 200.0

var direction: float = 1.0   # 1 = right, -1 = left

enum State { MOVE, DEAD }
var state = State.MOVE

var tide_controller: TideController = null

func _physics_process(_delta: float) -> void:
	if _get_water_y() > global_position.y:
		_die()

	if state == State.DEAD:
		return
	
	sprite.flip_v = direction < 0.0
	
	velocity.x = direction * SPEED
	velocity.y = 0.0
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.has_method("take_damage"):
			collider.take_damage()
			_die()
			return

	var screen_width = get_viewport_rect().size.x
	if global_position.x > get_viewport().get_camera_2d().get_screen_center_position().x + get_viewport_rect().size.x / 2.0 + 100 or global_position.x < get_viewport().get_camera_2d().get_screen_center_position().x - get_viewport_rect().size.x / 2.0 -100:
		queue_free()
		
func take_damage() -> void:
	_die()

func _get_water_y() -> float:
	return tide_controller.get_underwater_y_pos()

func _die() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	set_physics_process(false)
	queue_free()
