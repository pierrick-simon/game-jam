extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

var finished: bool = false
var rad: float = 0.0
var rad_incr: float = 1500.0

@export_subgroup("Settings")
@export var color: Color

signal end_level

func _process(delta: float) -> void:
	if rad > 1500:
		emit_signal("end_level")
		queue_free()
		return
	if finished:
		animated_sprite.visible = false
		rad += rad_incr * delta
		queue_redraw()
		return
	animated_sprite.play("heart")

func _on_animated_sprite_2d_animation_looped() -> void:
	finished = true

func _draw() -> void:
	draw_circle(Vector2.ZERO, rad, color)
