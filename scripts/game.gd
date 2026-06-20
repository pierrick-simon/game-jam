extends Node2D

@export_subgroup("Settings")
@export var levels: Array[String]

var level_index: int = 0
var level_instance: Node

func _ready() -> void:
	_instanciate_new_level(levels[level_index])

func _process(delta: float) -> void:
	pass

func _instanciate_new_level(level_path: String) -> void:
	if level_instance != null:
		remove_child(level_instance)
	var level_scene: PackedScene = load("scenes/levels/" + level_path + ".tscn")
	level_instance = level_scene.instantiate()
	level_instance.end_level.connect(_end_level)
	add_child(level_instance)

func _end_level() -> void:
	level_index += 1
	if level_index >= levels.size():
		get_tree().quit()
		return
	_instanciate_new_level(levels[level_index])
