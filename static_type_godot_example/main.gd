extends Control

@onready var rich_text_label: RichTextLabel = %RichTextLabel

const ITERATIONS: int = 1_000_000
const WARMUP_ITERATIONS: int = 1_000

# Test variables
var untyped_int = 0
var typed_int: int = 0
var untyped_float = 0.0
var typed_float: float = 0.0
var untyped_vector = Vector2.ZERO
var typed_vector: Vector2 = Vector2.ZERO
var untyped_string = ""
var typed_string: String = ""

var results: Dictionary = {}

func _ready() -> void:
	rich_text_label.clear()
	_print_header()
	
	_warmup()
	_run_all_tests()
	_print_results()

func _print_header() -> void:
	rich_text_label.append_text("[center][color=#FFA500]Static Typing Performance Analysis[/color]\n")
	rich_text_label.append_text("[color=#888888]Godot 4.4 - Debug Build[/color]\n")
	rich_text_label.append_text("=================================\n\n")
	rich_text_label.append_text("[color=#FFA500]Test Configuration:[/color]\n")
	rich_text_label.append_text("Iterations: [color=#FFFFFF]{0}[/color]\n".format([ITERATIONS]))
	rich_text_label.append_text("Warmup Cycles: [color=#FFFFFF]{0}[/color]\n\n".format([WARMUP_ITERATIONS]))

func _warmup() -> void:
	rich_text_label.append_text("[color=#888888]Warming up engine...[/color]\n\n")
	for i in WARMUP_ITERATIONS:
		var temp = 0
		temp += 1

func _run_all_tests() -> void:
	_test_integer_operations()
	_test_float_operations()
	_test_vector_operations()
	_test_string_operations()

func _time_function(test_func: Callable) -> float:
	var start_time = Time.get_ticks_msec()
	test_func.call()
	var end_time = Time.get_ticks_msec()
	return end_time - start_time

func _get_performance_color(improvement: float) -> String:
	if improvement >= 30.0:
		return "#00FF00" # Bright green for excellent
	elif improvement >= 20.0:
		return "#90EE90" # Light green for good
	elif improvement >= 10.0:
		return "#FFD700" # Gold for moderate
	elif improvement >= 5.0:
		return "#FFA500" # Orange for minor
	else:
		return "#FF6347" # Tomato for minimal

func _print_column_headers() -> void:
	rich_text_label.append_text("[table=5]")
	rich_text_label.append_text("[cell][color=#FFA500]Operation Type[/color][/cell]")
	rich_text_label.append_text("[cell][color=#FFA500]Untyped (ms)[/color][/cell]")
	rich_text_label.append_text("[cell][color=#FFA500]Typed (ms)[/color][/cell]")
	rich_text_label.append_text("[cell][color=#FFA500]Improvement[/color][/cell]")
	rich_text_label.append_text("[cell][color=#FFA500]Operations/sec[/color][/cell]")
	rich_text_label.append_text("[/table]\n")

func _format_ops_per_second(time_ms: float) -> String:
	var ops_per_sec = ITERATIONS / (time_ms / 1000.0)
	if ops_per_sec >= 1_000_000:
		return "%.2fM" % (ops_per_sec / 1_000_000)
	elif ops_per_sec >= 1_000:
		return "%.2fK" % (ops_per_sec / 1_000)
	else:
		return "%.2f" % ops_per_sec

func _test_integer_operations() -> void:
	# Test implementation remains the same
	var untyped_time = _time_function(func():
		for i in ITERATIONS:
			untyped_int += 1
			untyped_int *= 2
			untyped_int /= 2
	)
	
	var typed_time = _time_function(func():
		for i in ITERATIONS:
			typed_int += 1
			typed_int *= 2
			typed_int /= 2
	)
	
	results["integer"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}


func _test_float_operations() -> void:
	var untyped_time = _time_function(func():
		for i in ITERATIONS:
			untyped_float += 1.5
			untyped_float *= 1.5
			untyped_float /= 1.5
	)
	
	var typed_time = _time_function(func():
		for i in ITERATIONS:
			typed_float += 1.5
			typed_float *= 1.5
			typed_float /= 1.5
	)
	
	results["float"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}

func _test_vector_operations() -> void:
	var untyped_time = _time_function(func():
		for i in ITERATIONS:
			untyped_vector += Vector2.ONE
			untyped_vector *= 1.5
			untyped_vector = untyped_vector.normalized()
			var _dist = untyped_vector.distance_to(Vector2.ZERO)
	)
	
	var typed_time = _time_function(func():
		for i in ITERATIONS:
			typed_vector += Vector2.ONE
			typed_vector *= 1.5
			typed_vector = typed_vector.normalized()
			var _dist = typed_vector.distance_to(Vector2.ZERO)
	)
	
	results["vector"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}

func _test_string_operations() -> void:
	var untyped_time = _time_function(func():
		for i in ITERATIONS:
			untyped_string = "test"
			untyped_string += "_suffix"
			untyped_string = untyped_string.substr(0, 4)
	)
	
	var typed_time = _time_function(func():
		for i in ITERATIONS:
			typed_string = "test"
			typed_string += "_suffix"
			typed_string = typed_string.substr(0, 4)
	)
	
	results["string"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}

func _print_results() -> void:
	rich_text_label.append_text("[color=#FFA500]Performance Analysis Results[/color]\n")
	rich_text_label.append_text("===========================\n\n")
	
	_print_column_headers()
	
	for test_name in results:
		var test = results[test_name]
		var improvement = test.improvement
		var perf_color = _get_performance_color(improvement)
		
		rich_text_label.append_text("[table=5]")
		# Operation type
		rich_text_label.append_text("[cell][color=#FFA500]{0}[/color][/cell]".format([test_name.capitalize()]))
		# Untyped time
		rich_text_label.append_text("[cell][color=yellow]%.2f[/color][/cell]" % test.untyped)
		# Typed time
		rich_text_label.append_text("[cell][color=#00FF00]%.2f[/color][/cell]" % test.typed)
		# Improvement percentage with color
		rich_text_label.append_text("[cell][color={0}]%.2f%%[/color][/cell]".format([perf_color]) % improvement)
		# Operations per second
		rich_text_label.append_text("[cell][color=#FFFFFF]{0}[/color][/cell]".format([test.ops_per_sec_typed]))
		rich_text_label.append_text("[/table]\n")
	
	rich_text_label.append_text("\n[color=#888888]Note: Higher improvement percentages indicate better performance gains from static typing.[/color]\n")
	rich_text_label.append_text("[color=#888888]Operations/sec shows the number of operations possible per second with typed variables.[/color]")
