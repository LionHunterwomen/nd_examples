class_name IconArea
extends Area3D

## 安全版本的获取对象
func get_icon() -> Icon:
	return get_parent().get_parent() as Icon
