extends Node2D

@onready var area = %Area2D

signal has_entered_finish

var is_finished: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_finished:
		return
	emit_signal("has_entered_finish")
	is_finished = true
