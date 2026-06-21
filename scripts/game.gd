extends Node2D

@export_subgroup("Settings")
@export var levels: Array[String]

@onready var main_menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
@onready var click: Node = %Click

var level_index: int = 0
var level_instance: Node
var main_menu_instance: Node
var pause: bool = false

enum state {
	main_menu,
	game
}

func _ready() -> void:
	var pause: Node = get_node("Pause")
	pause.get_node("Play").pressed.connect(_replay)
	pause.get_node("Restart").pressed.connect(_restart)
	pause.get_node("Home").pressed.connect(_home)
	pause.get_node("Quit").pressed.connect(_quit)
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
		level_index = 0
		_main_menu()
		return
	_instanciate_new_level(levels[level_index])

func _main_menu():
	_close_instances()
	main_menu_instance = main_menu_scene.instantiate()
	main_menu_instance.get_node("Play").pressed.connect(_play)
	main_menu_instance.get_node("Quit").pressed.connect(_quit)
	add_child(main_menu_instance)

func _play() -> void:
	click.play()
	_instanciate_new_level(levels[level_index])

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and level_instance != null:
		if pause:
			level_instance.process_mode = Node.PROCESS_MODE_INHERIT
			get_node("Pause").visible = false
			pause = false
		elif level_instance.rad <= 0 and level_instance.star_anim == null:
			level_instance.process_mode = Node.PROCESS_MODE_DISABLED
			get_node("Pause").visible = true
			pause = true

func _quit() -> void:
	get_tree().quit()

func _replay() -> void:
	click.play()
	if level_instance != null:
		level_instance.process_mode = Node.PROCESS_MODE_INHERIT
		get_node("Pause").visible = false
		pause = false

func _restart() -> void:
	click.play()
	_instanciate_new_level(levels[level_index])
	level_instance.process_mode = Node.PROCESS_MODE_INHERIT
	get_node("Pause").visible = false
	pause = false

func _home() -> void:
	click.play()
	_main_menu()
	level_instance.process_mode = Node.PROCESS_MODE_INHERIT
	get_node("Pause").visible = false
	pause = false
