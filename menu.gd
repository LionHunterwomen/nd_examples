class_name Menu
extends PanelContainer

@onready var list: VBoxContainer = %ListContainer as VBoxContainer

var root_path: String = "res://examples"

signal do_change_scene(path: String)

func _ready() -> void:
	var dirs: PackedStringArray = DirAccess.get_directories_at(root_path)
	for dir in dirs:
		var path: String = root_path.path_join(dir)
		
		var files: PackedStringArray = DirAccess.get_files_at(path)
		if files.has("main.tscn"):
			var button: Button = Button.new()
			button.text = dir
			button.add_theme_font_size_override("font_size", 32)
			button.focus_mode = Control.FOCUS_NONE
			list.add_child(button)
			
			button.pressed.connect(
				func() -> void:
					do_change_scene.emit(path.path_join("main.tscn"))
			)
