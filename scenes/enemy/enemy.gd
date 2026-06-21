extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const DIVE_SPEED = 320.0
const GLIDE_SPEED = 180.0

enum State { GLIDE, DIVE, DEAD }
var state = State.GLIDE
var target_x: float = 0.0

func _ready() -> void:
	animated_sprite.play("fly")

func _physics_process(_delta: float) -> void:
	match state:
		State.GLIDE:
			var dir = sign(target_x - global_position.x)
			velocity.x = dir * GLIDE_SPEED
			velocity.y = 0.0
			if abs(global_position.x - target_x) < 8.0:
				state = State.DIVE

		State.DIVE:
			velocity.x = 0.0
			velocity.y = DIVE_SPEED

		State.DEAD:
			return

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.has_method("take_damage"):
			collider.take_damage()
			_die()
			return

	if global_position.y > 2000.0:
		queue_free()

func _die() -> void:
	if state == State.DEAD:
		return
	state = State.DEAD
	set_physics_process(false)
	queue_free()
