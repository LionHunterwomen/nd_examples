extends Node

@onready var button: Button = $CanvasLayer/Button as Button
@onready var rich_text_label: RichTextLabel = $CanvasLayer/RichTextLabel as RichTextLabel

func _ready() -> void:
	button.pressed.connect(flash_data)
	pass

func flash_data() -> void:
	var data: Dictionary = await get_fafang_pressure_data()
	rich_text_label.text = str(data)

## 通过输入开始日期与结束日期返回阀房的压力数据，如果不输入，则返回2023-8-1至2023-8-8的数据
func get_fafang_pressure_data(start_day: String = "", end_day: String = "") -> Dictionary:
	var http: HTTPRequest = _get_http()
	
	## 请求的网址
	var url: String = "http://42.63.155.42:4055/ex_api/get_digital_twin_data/press_point/"
	## 请求时的request_data
	var data: String = ""
	## 如果没有输入则使用默认日期
	if start_day.is_empty() or end_day.is_empty():
		data = """{ "token": "b3BlbnNzqC1rZXktdj1234567", "s_time": "2023-8-1", "e_time": "2023-8-8"}"""
	else:
		data = """{ "token": "b3BlbnNzqC1rZXktdj1234567", "s_time": "%s", "e_time": "%s"}""" % [start_day, end_day]
	## 请求数据，第二个空的数组是headers
	var err = http.request(url, [] , HTTPClient.METHOD_POST, data)
	## 如果请求失败则打印失败信息并释放掉[HTTPRequest]节点，返回一个空节点
	if err != OK:
		http.queue_free()
		printerr("request faild:\t", err)
		return {}
	## 等待请求完成，返回数据，await关键字就是起async/await中的await作用
	var result: Array = await http.request_completed
	## 返回数据中有效的部分，如果没有则返回空字典
	if result[3].is_empty():
		return {}
	return JSON.parse_string(result[3].get_string_from_utf8())

## 创建并返回一个[HTTPRequest]，在[HTTPRequest]返回结果后释放掉
func _get_http() -> HTTPRequest:
	var http: HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_free_http.bind(http))
	return http

func _free_http(_result: int, _response_code: int, _headers: PackedStringArray, _body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
