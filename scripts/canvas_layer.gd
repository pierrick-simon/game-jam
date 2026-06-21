extends Node2D

var world

func _ready() -> void:
	world = get_parent().get_parent()

func _draw() -> void:
	if world == null:
		return
	var pos = world.get_node("Player").position
	draw_circle(pos, world.rad, world.color)
