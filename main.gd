extends Node

@onready var menu: Menu = $GUI/Menu as Menu

var current_example: Node

func _ready() -> void:
	menu.do_change_scene.connect(load_scene)


func load_scene(path: String) -> void:
	ResourceLoader.load_threaded_request(path)
	while true:
		match ResourceLoader.load_threaded_get_status(path):
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await get_tree().process_frame
			ResourceLoader.THREAD_LOAD_LOADED:
				var ps: PackedScene = ResourceLoader.load_threaded_get(path) as PackedScene
				change_scene(ps)
			_:
				break

func change_scene(ps: PackedScene) -> void:
	if is_instance_valid(current_example):
		current_example.queue_free()
	
	current_example = ps.instantiate()
	add_child(current_example)
