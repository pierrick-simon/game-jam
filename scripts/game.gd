extends Node2D

@export_subgroup("Settings")
@export var levels: Array[String]

@onready var main_menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")

var level_index: int = 0
var level_instance: Node
var main_menu_instance: Node

enum state {
	main_menu,
	game
}

func _ready() -> void:
	_main_menu()

func _process(delta: float) -> void:
	pass

func _instanciate_new_level(level_path: String) -> void:
	_close_instances()
	var level_scene: PackedScene = load("scenes/levels/" + level_path + ".tscn")
	level_instance = level_scene.instantiate()
	level_instance.end_level.connect(_end_level)
	add_child(level_instance)

func _close_instances() -> void:
	if level_instance != null:
		remove_child(level_instance)
	if main_menu_instance != null:
		remove_child(main_menu_instance)

func _end_level() -> void:
	level_index += 1
	if level_index >= levels.size():
		get_tree().quit()
		return
	_instanciate_new_level(levels[level_index])

func _main_menu():
	_close_instances()
	main_menu_instance = main_menu_scene.instantiate()
	main_menu_instance.get_node("Play").pressed.connect(_play)
	add_child(main_menu_instance)

func _play() -> void:
	_instanciate_new_level(levels[level_index])
