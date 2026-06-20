extends Node2D

var world

func _ready() -> void:
	world = get_parent().get_parent()

func _draw() -> void:
	if world == null:
		return
	var pos = get_viewport().get_canvas_transform().affine_inverse() * world.player.global_position
	draw_circle(pos, world.rad, world.color)
