extends Node2D

@onready var star_anim_scene: PackedScene = preload("res://scenes/star_anim.tscn")
@onready var seagull_scene: PackedScene = preload("res://scenes/enemy/enemy.tscn")
@onready var net_scene: PackedScene = preload("res://scenes/enemy/net.tscn")
@onready var chicken_scene: PackedScene = preload("res://scenes/chicken.tscn")
@onready var end_npc = %EndNPC
@onready var player = $Player
@onready var circle_drawer = $CanvasLayer/CircleDrawer
@onready var found = %Found
@onready var tide_controller: TideController = $TideController

var rad: float = 1500.0
var rad_incr: float = 1500.0
var star_anim: Node

@export_subgroup("Settings")
@export var color: Color

# --- seagull settings ---
@export_subgroup("Seagull")
@export var spawn_interval_seagull: float = 5.0
@export var spawn_interval_net: float = 5.0
@export var spawn_interval_chicken: float = 15.0
@export var random_spawn: bool = false
@export var level_x_min: float = 0.0
@export var level_x_max: float = 2000.0
@export var spawn_y_offset: float = -800.0

var _seagull_timer: float = 0.0
var _net_timer: float = 0.0
var _chicken_timer: float = 0.0
var _can_spawn: bool = false

signal can_start
signal end_level

func _ready() -> void:
	player.on_death.connect(_clear)

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
	if _seagull_timer >= spawn_interval_seagull:
		_seagull_timer = 0.0
		_spawn_seagull()
	_net_timer += delta
	if _net_timer >= spawn_interval_net:
		_net_timer = 0.0
		_spawn_net()
	_chicken_timer += delta
	if _chicken_timer >= spawn_interval_chicken:
		_chicken_timer = 0.0
		_spawn_chicken()
		
func _get_water_y() -> float:
	return tide_controller.get_underwater_y_pos()

func _spawn_seagull() -> void:
	if player.global_position.y >= _get_water_y():
		return
		
	var gull = seagull_scene.instantiate()
	$SpawnedObjects.add_child(gull)
	gull.tide_controller = tide_controller

	var spawn_x: float
	if random_spawn:
		spawn_x = randf_range(level_x_min, level_x_max)
	else:
		spawn_x = player.global_position.x + randf_range(-60, 60)

	gull.global_position = Vector2(spawn_x, player.global_position.y + spawn_y_offset)
	gull.target_x = player.global_position.x

func _spawn_chicken() -> void:
	var chicken = chicken_scene.instantiate()
	$SpawnedObjects.add_child(chicken)
	chicken.tide_controller = tide_controller
	var sreen_left = get_viewport().get_camera_2d().get_screen_center_position().x - get_viewport_rect().size.x / 2.0
	chicken.global_position = Vector2(sreen_left, 600)
	
func _spawn_net() -> void:
	if player.global_position.y < _get_water_y():
		return
	var net = net_scene.instantiate()
	$SpawnedObjects.add_child(net)
	net.tide_controller = tide_controller
	var screen_size = get_viewport_rect().size
	var sreen_left = get_viewport().get_camera_2d().get_screen_center_position().x - get_viewport_rect().size.x / 2.0
	if randf() > 0.5:
		net.direction = 1.0
		net.global_position = Vector2(sreen_left - 50, randf_range(_get_water_y(), screen_size.y))
	else:
		net.direction = -1.0
		net.global_position = Vector2(sreen_left + screen_size.x + 50, randf_range(_get_water_y(), screen_size.y))

func _on_end_npc_has_entered_finish() -> void:
	found.play()
	_can_spawn = false
	star_anim = star_anim_scene.instantiate()
	star_anim.position = Vector2((player.position.x + end_npc.position.x) / 2, end_npc.position.y - 60)
	star_anim.end_level.connect(_end_level_anim)
	add_child(star_anim)

func _end_level_anim() -> void:
	emit_signal("end_level")

func _clear() -> void:
	for object in $SpawnedObjects.get_children():
		object.queue_free()
	%TideController.reset_tide()
