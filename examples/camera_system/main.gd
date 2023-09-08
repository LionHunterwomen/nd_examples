extends Node3D

@onready var button_list: HBoxContainer = %ButtonList as HBoxContainer

var _cameras: Dictionary = {}
var _main_camera_3d: CameraGimbal

const CameraGroupName: String = "相机结构"
const MainCameraGroupName: String = "主相机"

var _current_tween: Tween

var _inited: bool = false

func _ready() -> void:
	
	do_init()
	move_camera("鸟瞰")
	
	for n in get_camera_names():
		var button: Button = Button.new()
		button.text = n
		button_list.add_child(button)
		button.pressed.connect(
			func() -> void:
				move_camera(n)
		)

func do_init() -> void:
	if _inited:
		printerr("重复的初始化\t", get_stack())
		return
	_init_camera_dic()
	_init_main_camera_3d()
	_inited = true

## 获取该场景下所有相机构造体的信息
func _init_camera_dic() -> void:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(CameraGroupName)
	for cs in nodes:
		if not cs is CameraStruct:
			printerr("错误的输入\t", cs.get_path())
			continue
		
		cs = cs as CameraStruct
		cs.hide()
		if _cameras.keys().has(cs.name):
			printerr("重复的相机\t", cs.get_path())
			continue
		
		_cameras[cs.name] = cs

## 获取该场景下的[CameraGimbal]
func _init_main_camera_3d() -> void:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(MainCameraGroupName)
	for camera in nodes:
		if not camera is CameraGimbal:
			printerr("错误的输入\t", camera.get_path())
			continue
		
		camera = camera as CameraGimbal
		if _main_camera_3d != null:
			printerr("重复的主相机", camera)
			continue
		
		_main_camera_3d = camera
	
	if _main_camera_3d == null:
		printerr("缺失主相机")

## 返回在 _init_camera_dic 中注册的所有相机构造体的名称
func get_camera_names() -> Array[String]:
	if not _inited:
		printerr("未初始化")
		return []
	var keys: Array[String] = []
	for key in _cameras.keys():
		if not key is String:
			printerr("有错误的相机输入， 请勿手动输入相机")
			continue
		keys.push_back(key)
	return keys

## 移动主相机至目标相机位，target_camera_name是相机位名称，duration是移动时间，transition_type是移动速度的曲线类型
func move_camera(target_camera_name: String, duration: float = 1.0, transition_type: Tween.TransitionType = Tween.TRANS_CIRC) -> void:
	_move_main_camera(target_camera_name, duration, transition_type)
	_move_main_camera(target_camera_name, duration, transition_type)

## WARNING: 未知原因导致必须调用两次才能正常工作
func _move_main_camera(target_camera_name: String, duration: float = 1.0, transition_type: Tween.TransitionType = Tween.TRANS_CIRC) -> void:
	if not _inited:
		printerr("未初始化")
		return
	
	if not _cameras.keys().has(target_camera_name):
		printerr("不存在的相机\t", target_camera_name)
		return
	
	if _main_camera_3d == null:
		printerr("主相机不存在")
		return
	
	var target_camera: CameraStruct = _cameras.get(target_camera_name) as CameraStruct
	
	match target_camera.get_type():
		CameraStruct.Type.ORBIT:
			
			_current_tween = create_tween()
			_current_tween.tween_callback(_main_camera_3d.switch_movement_type.bind(CameraGimbal.Type.NONE))
			_current_tween.chain().tween_property(_main_camera_3d._character_body, "global_transform", target_camera.get_camera_transform(), duration)
			_current_tween.chain().tween_callback(_main_camera_3d.set_looking_at.bind(target_camera.get_target_position()))
			_current_tween.chain().tween_callback(_main_camera_3d.switch_movement_type.bind(CameraGimbal.Type.ORBIT))
		CameraStruct.Type.FIRST_PERSON:
			_current_tween = create_tween()
			_current_tween.tween_callback(_main_camera_3d.switch_movement_type.bind(CameraGimbal.Type.NONE))
			_current_tween.chain().tween_property(_main_camera_3d._character_body, "global_transform", target_camera.get_camera_transform(), duration).set_trans(transition_type).set_ease(Tween.EASE_OUT)
			_current_tween.chain().tween_callback(_main_camera_3d.switch_movement_type.bind(CameraGimbal.Type.FIRST_PERSON))
