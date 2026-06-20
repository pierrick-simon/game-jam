extends Node2D

@onready var star_anim_scene: PackedScene = preload("res://scenes/star_anim.tscn")
@onready var end_npc = %EndNPC
@onready var player = $Player
@onready var circle_drawer = $CanvasLayer/CircleDrawer

var rad: float = 1500.0

var rad_incr: float = 500.0

@export_subgroup("Settings")
@export var color: Color

func _process(delta: float) -> void:
	if rad >= 0:
		rad -= rad_incr * delta
		if rad < 0:
			rad = 0
		circle_drawer.queue_redraw()

func _on_end_npc_has_entered_finish() -> void:
	var star_anim = star_anim_scene.instantiate()
	star_anim.position = Vector2((player.position.x + end_npc.position.x) / 2, end_npc.position.y - 60)
	add_child(star_anim)
