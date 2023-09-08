extends CanvasLayer

@onready var menu: PanelContainer = $Menu as PanelContainer

var menu_is_show: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if  menu.get_global_rect().has_point(event.position):
			show_menu()
		else:
			hide_menu()

func show_menu() -> void:
	var tween: Tween = menu.create_tween()
	tween.tween_property(menu, "position:x", 0.0, 0.3)
	menu_is_show = true

func hide_menu() -> void:
	var tween: Tween = menu.create_tween()
	tween.tween_property(menu, "position:x", -menu.get_rect().size.x + 10, 0.3)
	menu_is_show = false
