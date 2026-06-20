extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

var finished: bool = false;

func _process(delta: float) -> void:
	if finished:
		animated_sprite.visible = false
		return
	animated_sprite.play("heart")

func _on_animated_sprite_2d_animation_looped() -> void:
	queue_free()
