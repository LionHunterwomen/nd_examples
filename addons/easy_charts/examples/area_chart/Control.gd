extends Control

@onready var chart: Chart = $VBoxContainer/Chart

# This Chart will plot 3 different functions
var f1: Function
var f2: Function

func _ready():
	# Let's create our @x values
#	var x: Array = ArrayOperations.multiply_float(range(-10, 11, 1), 0.5)
	var x: Array = ["Day 1", "Day 2", "Day 3", "Day 4"]
	
	# And our y values. It can be an n-size array of arrays.
	# NOTE: `x.size() == y.size()` or `x.size() == y[n].size()`
#	var y: Array = ArrayOperations.multiply_int(ArrayOperations.cos(x), 20)
	var y1: Array = [20, 10, 50, 30]
	var y2: Array = [20, 10, 50, 30]
	
	# Let's customize the chart properties, which specify how the chart
	# should look, plus some additional elements like labels, the scale, etc...
	var cp: ChartProperties = ChartProperties.new()
	cp.colors.frame = Color.TRANSPARENT
	cp.colors.background = Color.TRANSPARENT
	cp.colors.grid = Color(1.0, 1.0, 1.0, 0.11373)
	cp.colors.ticks = Color("#283442")
	cp.colors.text = Color.WHITE_SMOKE
	cp.draw_bounding_box = false
	cp.show_title = false
	cp.show_x_label = false
	cp.show_y_label = false
#	cp.x_scale = 5
	cp.y_scale = 5
	cp.interactive = true # false by default, it allows the chart to create a tooltip to show point values
	# and interecept clicks on the plot
	
	# Let's add values to our functions
	f1 = Function.new(
		x, y1, "实际压力", # This will create a function with x and y values taken by the Arrays 
						# we have created previously. This function will also be named "Pressure"
						# as it contains 'pressure' values.
						# If set, the name of a function will be used both in the Legend
						# (if enabled thourgh ChartProperties) and on the Tooltip (if enabled).
		# Let's also provide a dictionary of configuration parameters for this specific function.
		{ 
			color = Color("#36a2eb"), 		# The color associated to this function
			marker = Function.Marker.CIRCLE, 	# The marker that will be displayed for each drawn point (x,y)
											# since it is `NONE`, no marker will be shown.
			type = Function.Type.LINE, 		# This defines what kind of plotting will be used, 
											# in this case it will be an Area Chart.
		}
	)
	
	f2 = Function.new(x, y2, "预测压力", { color = Color("#cccccc"), marker = Function.Marker.CIRCLE, type = Function.Type.LINE})
	
	# Now let's plot our data
	chart.plot([f1, f2], cp)
	
	# Uncommenting this line will show how real time data plotting works
	set_process(false)
	
	foo()

func foo() -> void:
	var datas: Array = (await get_pressure_data())["data"]
	var order_time_data: Dictionary = {}
	
	for data in datas:
		var receive_time: String = data["receive_time"]
		if not order_time_data.has(receive_time):
			order_time_data[receive_time] = []
		(order_time_data[receive_time] as Array).append(data)
	
	var index: int = 0
	while true:
		var key = order_time_data.keys()[index]
		set_data(order_time_data[key])
		await get_tree().create_timer(5.0).timeout
		index = wrapi(index + 1, 0, order_time_data.keys().size())

func set_data(datas: Array) -> void:
#	var x: Array = []
#	var y: Array = []
	f1.x.clear()
	f1.y.clear()
	f2.x.clear()
	f2.y.clear()
	for data in datas:
#		x.push_back(data["number"])
#		y.push_back(data["pressNumber"])
		f1.x.push_back(data["number"])
		f1.y.push_back(float(data["pressNumber"]))
		f2.x.push_back(data["number"])
		f2.y.push_back(float(data["forecast"]) * 0.8)
#	f1.x = x
#	f1.y = y
	chart.queue_redraw()

var new_val: float = 4.5

func _process(delta: float):
	# This function updates the values of a function and then updates the plot
	new_val += 5
	
	# we can use the `Function.add_point(x, y)` method to update a function
	f1.add_point(new_val, cos(new_val) * 20)
	chart.queue_redraw() # This will force the Chart to be updated


func _on_CheckButton_pressed():
	set_process(not is_processing())

func get_pressure_data() -> Dictionary:
	var http: HTTPRequest = _get_http()
	
	var url: String = "http://42.63.155.42:4055/ex_api/get_digital_twin_data/press_point/"
	var data: String = """{ "token": "b3BlbnNzqC1rZXktdj1234567", "s_time": "2023-8-1", "e_time": "2023-8-8"}"""
	var err = http.request(url,[] , HTTPClient.METHOD_POST, data)
	if err != OK:
		printerr(err)
		return {}
	var result: Array = await http.request_completed
	if result[3].is_empty():
		return JSON.parse_string("{}")
	return JSON.parse_string(result[3].get_string_from_utf8())

func _get_http() -> HTTPRequest:
	if has_meta("http_request_node"):
		return get_meta("http_request_node")
	else:
		var http: HTTPRequest = HTTPRequest.new()
		add_child(http)
		set_meta("http_request_node", http)
		return http
