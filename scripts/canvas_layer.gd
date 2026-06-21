extends Node2D

var world

func _ready() -> void:
	world = get_parent().get_parent()

func _draw() -> void:
	if world == null:
		return
	var win_size = DisplayServer.window_get_size()
	var pos = Vector2(win_size.x / 2, win_size.y / 2 + 30)
	draw_circle(pos, world.rad, world.color)
