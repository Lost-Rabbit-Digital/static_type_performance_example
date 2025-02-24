extends Control

# Configuration Section
@onready var label_information: RichTextLabel = %LabelInformation

# Results Section
@onready var label_current_status: RichTextLabel = %LabelCurrentStatus
@onready var label_results: RichTextLabel = %LabelResults

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

var results_data: Dictionary = {}

func _ready() -> void:
	_setup_configuration_section()
	_warmup()
	_run_all_tests()
	_display_results()

func _setup_configuration_section() -> void:
	label_information.text = """Information on the test
	Iterations: {0}
	Warmup Cycles: {1}""".format([ITERATIONS, WARMUP_ITERATIONS])

func _warmup() -> void:
	label_current_status.text = "Warming up the engines..."
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

func _format_ops_per_second(time_ms: float) -> String:
	var ops_per_sec = ITERATIONS / (time_ms / 1000.0)
	if ops_per_sec >= 1_000_000:
		return "%.2fM" % (ops_per_sec / 1_000_000)
	elif ops_per_sec >= 1_000:
		return "%.2fK" % (ops_per_sec / 1_000)
	else:
		return "%.2f" % ops_per_sec

func _display_results() -> void:
	label_current_status.text = "Completed the benchmark"
	
	var results_text = ""
	for test_name in results_data:
		var test = results_data[test_name]
		results_text += "%s: %.2fms -> %.2fms (%.2f%% improvement, %s ops/sec)\n" % [
			test_name.capitalize(),
			test.untyped,
			test.typed,
			test.improvement,
			test.ops_per_sec_typed
		]
	
	label_results.text = results_text

func _test_integer_operations() -> void:
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
	
	results_data["integer"] = {
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
	
	results_data["float"] = {
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
	
	results_data["vector"] = {
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
	
	results_data["string"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
