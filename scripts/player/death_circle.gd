class_name DeathCircle
extends Node2D

var death_radius: float = 0

func set_death_radius(t: float) -> void:
	death_radius = t
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, death_radius, Color8(255, 110, 110))
