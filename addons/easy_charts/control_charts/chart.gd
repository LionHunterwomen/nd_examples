@icon("res://addons/easy_charts/utilities/icons/linechart.svg")
extends PanelContainer
class_name Chart

@onready var _canvas: Canvas = $Canvas
@onready var plot_box: PlotBox = $"%PlotBox"
@onready var grid_box: GridBox = $"%GridBox"
@onready var functions_box: Control = $"%FunctionsBox"
@onready var function_legend: FunctionLegend = $"%FunctionLegend"

var functions: Array = []
var x: Array = []
var y: Array = []

var x_labels: PackedStringArray = []
var y_labels: PackedStringArray = []

var chart_properties: ChartProperties = ChartProperties.new()

###########

func plot(functions: Array[Function], properties: ChartProperties = ChartProperties.new()) -> void:
	self.functions = functions
	self.chart_properties = properties
	
	theme.set("default_font", self.chart_properties.font)
	_canvas.prepare_canvas(self.chart_properties)
	plot_box.chart_properties = self.chart_properties
	function_legend.chart_properties = self.chart_properties
	
	load_functions(functions)

func get_function_plotter(function: Function) -> FunctionPlotter:
	var plotter: FunctionPlotter
	match function.get_type():
		Function.Type.LINE:
			plotter = LinePlotter.new(function)
		Function.Type.AREA:
			plotter = AreaPlotter.new(function)
		Function.Type.PIE:
			plotter = PiePlotter.new(function)
		Function.Type.BAR:
			plotter = BarPlotter.new(function)
		Function.Type.SCATTER, _:
			plotter = ScatterPlotter.new(function)
	return plotter

func load_functions(functions: Array[Function]) -> void:
	self.x = []
	self.y = []
	
	function_legend.clear()
	
	for function in functions:
		# Load x and y values
		self.x.append(function.x)
		self.y.append(function.y)
		
		# Load Labels
		if self.x_labels.is_empty():
			if ECUtilities._contains_string(function.x):
				self.x_labels = function.x
		
		# Create FunctionPlotter
		var function_plotter: FunctionPlotter = get_function_plotter(function)
		function_plotter.connect("point_entered", Callable(plot_box, "_on_point_entered"))
		function_plotter.connect("point_exited", Callable(plot_box, "_on_point_exited"))
		functions_box.add_child(function_plotter)
		
		# Create legend
		match function.get_type():
			Function.Type.PIE:
				for i in function.x.size():
					var interp_color: Color = function.get_gradient().sample(float(i) / float(function.x.size()))
					function_legend.add_label(function.get_type(), interp_color, Function.Marker.NONE, function.y[i])
			_:
				function_legend.add_function(function)

func _draw() -> void:
	# GridBox
	var x_domain: Dictionary = calculate_domain(x)
	var y_domain: Dictionary = calculate_domain(y)
#	print(x_domain)
#	print(y_domain)
	
	var plotbox_margins: Vector2 = calculate_plotbox_margins(x_domain, y_domain)
	
	if ECUtilities._contains_string(x[0]):
		if chart_properties.x_scale > 0:
			x_labels.clear()
			for i in chart_properties.x_scale + 1:
				var index: int = int(lerp(0.0, float(x[0].size() - 1), float(i) / float(chart_properties.x_scale)))
				index = min(index, x[0].size() - 1)
				x_labels.append(x[0][index])
		else:
			self.x_labels = x[0]
	# Update values for the PlotBox in order to propagate them to the children
	plot_box.box_margins = plotbox_margins
	
	# Update GridBox
	update_gridbox(x_domain, y_domain, self.x_labels, self.y_labels)
	
	# Update each FunctionPlotter in FunctionsBox
	for function_plotter in functions_box.get_children():
		function_plotter.update_values(x_domain, y_domain)

func calculate_domain(values: Array) -> Dictionary:
	for value_array in values:
		if ECUtilities._contains_string(value_array):
			return { lb = 0.0, ub = (value_array.size() - 1), has_decimals = false }
	var min_max: Dictionary = ECUtilities._find_min_max(values)
	#return { lb = ECUtilities._round_min(min_max.min), ub = ECUtilities._round_max(min_max.max), has_decimals = ECUtilities._has_decimals(values) }
	return {lb = min_max.min, ub = min_max.max, has_decimals = ECUtilities._has_decimals(values)}

func update_gridbox(x_domain: Dictionary, y_domain: Dictionary, x_labels: PackedStringArray, y_labels: PackedStringArray) -> void:
	grid_box.set_domains(x_domain, y_domain)
	grid_box.set_labels(x_labels, y_labels)
	grid_box.queue_redraw()

func calculate_plotbox_margins(x_domain: Dictionary, y_domain: Dictionary) -> Vector2:
	var plotbox_margins: Vector2 = Vector2(
		chart_properties.x_tick_size,
		chart_properties.y_tick_size
	)
	
	if chart_properties.show_tick_labels:
		var x_ticklabel_size: Vector2
		var y_ticklabel_size: Vector2
		
		var y_max_formatted: String = ECUtilities._format_value(y_domain.ub, y_domain.has_decimals)
		if y_domain.lb < 0: # negative number
			var y_min_formatted: String = ECUtilities._format_value(y_domain.lb, y_domain.has_decimals)
			if y_min_formatted.length() >= y_max_formatted.length():
				y_ticklabel_size = chart_properties.get_string_size(y_min_formatted)
			else:
				y_ticklabel_size = chart_properties.get_string_size(y_max_formatted)
		else:
			y_ticklabel_size = chart_properties.get_string_size(y_max_formatted)
		
		plotbox_margins.x += y_ticklabel_size.x + chart_properties.x_ticklabel_space
		plotbox_margins.y += ThemeDB.fallback_font_size + chart_properties.y_ticklabel_space
	
	return plotbox_margins
