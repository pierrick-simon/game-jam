extends Node2D

@onready var star_anim_scene: PackedScene = preload("res://scenes/star_anim.tscn")
@onready var seagull_scene: PackedScene = preload("res://scenes/enemy/enemy.tscn")
@onready var end_npc = %EndNPC
@onready var player = $Player
@onready var circle_drawer = $CanvasLayer/CircleDrawer
@onready var found = %Found

var rad: float = 1500.0
var rad_incr: float = 1500.0
var star_anim: Node

@export_subgroup("Settings")
@export var color: Color

# --- seagull settings ---
@export_subgroup("Seagull")
@export var spawn_interval: float = 5.0
@export var random_spawn: bool = false
@export var level_x_min: float = 0.0
@export var level_x_max: float = 2000.0
@export var spawn_y_offset: float = -800.0

var _seagull_timer: float = 0.0
var _can_spawn: bool = false

signal can_start
signal end_level

func _process(delta: float) -> void:
	# --- original intro circle ---
	if rad == 0:
		emit_signal("can_start")
		_can_spawn = true
	if rad >= 0:
		rad -= rad_incr * delta
		if rad < 0:
			rad = 0
		circle_drawer.queue_redraw()

	if not _can_spawn:
		return
	_seagull_timer += delta
	if _seagull_timer >= spawn_interval:
		_seagull_timer = 0.0
		_spawn_seagull()

func _spawn_seagull() -> void:
	var gull = seagull_scene.instantiate()
	add_child(gull)

	var spawn_x: float
	if random_spawn:
		spawn_x = randf_range(level_x_min, level_x_max)
	else:
		spawn_x = player.global_position.x + randf_range(-60, 60)

	gull.global_position = Vector2(spawn_x, player.global_position.y + spawn_y_offset)
	gull.target_x = player.global_position.x

func _on_end_npc_has_entered_finish() -> void:
	found.play()
	_can_spawn = false
	star_anim = star_anim_scene.instantiate()
	star_anim.position = Vector2((player.position.x + end_npc.position.x) / 2, end_npc.position.y - 60)
	star_anim.end_level.connect(_end_level_anim)
	add_child(star_anim)

func _end_level_anim() -> void:
	emit_signal("end_level")
