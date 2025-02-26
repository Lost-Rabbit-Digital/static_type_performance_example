extends Control

# Configuration Section
@onready var label_information: RichTextLabel = %LabelInformation
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var label_current_status: RichTextLabel = %LabelCurrentStatus
@onready var label_results: RichTextLabel = %LabelResults

const ITERATIONS: int = 25_000_000
const WARMUP_ITERATIONS: int = 10_000

# Threading
var thread: Thread
var mutex: Mutex
var is_running: bool = false
var current_progress: float = 0.0
var total_tests: int = 4  # integer, float, vector, string tests

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

signal test_completed(test_name: String, results: Dictionary)
signal progress_updated(value: float)

func _ready() -> void:
	label_results.bbcode_enabled = true
	mutex = Mutex.new()
	_setup_configuration_section()
	start_benchmark()

func _setup_configuration_section() -> void:
	label_information.text = """Information on the test
	Iterations: {0}
	Warmup Cycles: {1}""".format([ITERATIONS, WARMUP_ITERATIONS])

func start_benchmark() -> void:
	if is_running:
		return
		
	is_running = true
	current_progress = 0
	progress_bar.value = 0
	label_current_status.text = "Starting benchmark..."
	
	thread = Thread.new()
	thread.start(_run_benchmark_thread)

func _run_benchmark_thread() -> void:
	_warmup.call_deferred()
	
	# Run each test and update progress
	_test_integer_operations()
	_update_progress(25)
	
	_test_float_operations()
	_update_progress(50)
	
	_test_vector_operations()
	_update_progress(75)
	
	_test_string_operations()
	_update_progress(100)
	
	call_deferred("_benchmark_completed")

func _update_progress(value: float) -> void:
	mutex.lock()
	current_progress = value
	mutex.unlock()
	progress_updated.emit.call_deferred(value)

func _process(_delta: float) -> void:
	if is_running:
		mutex.lock()
		progress_bar.value = current_progress
		mutex.unlock()

func _benchmark_completed() -> void:
	is_running = false
	thread.wait_to_finish()
	progress_bar.value = current_progress
	label_current_status.text = "Completed the benchmark"
	_display_results()

func _warmup() -> void:
	label_current_status.text = "Processing warmup iterations..."
	for i in WARMUP_ITERATIONS:
		var temp = 0
		temp += 1

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

func _get_ms_color(ms: float) -> String:
	if ms < 100:
		return "00ff00"
	elif ms < 500:
		return "90ee90"
	elif ms < 1000:
		return "ffff00"
	elif ms < 2000:
		return "ffa500"
	else:
		return "ff0000"

func _get_performance_color(improvement: float) -> String:
	if improvement >= 20.0:
		return "00ff00"
	elif improvement >= 10.0:
		return "90ee90"
	elif improvement >= 5.0:
		return "ffff00"
	elif improvement >= 0.0:
		return "ffa500"
	else:
		return "ff0000"

func _get_ops_color(ops_str: String) -> String:
	if "M" in ops_str:
		return "00ff00"
	elif "K" in ops_str:
		if float(ops_str.replace("K", "")) >= 500:
			return "90ee90"
		else:
			return "ffff00"
	else:
		return "ff0000"

func _display_results() -> void:
	var results_text = ""
	for test_name in results_data:
		var test = results_data[test_name]
		var perf_color = _get_performance_color(test.improvement)
		var ops_color = _get_ops_color(test.ops_per_sec_typed)
		
		results_text += "%s:\n" % test_name.capitalize()
		var untyped_color = "ff0000" if test.untyped > test.typed else _get_ms_color(test.untyped)
		var typed_color = _get_ms_color(test.typed)
		results_text += "  [color=#%s]%.2fms[/color] -> [color=#%s]%.2fms[/color] | " % [untyped_color, test.untyped, typed_color, test.typed]
		results_text += "[color=#%s](%.2f%% improvement)[/color] | " % [perf_color, test.improvement]
		results_text += "[color=#%s]%s ops/sec[/color]\n" % [ops_color, test.ops_per_sec_typed]
	
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
	
	mutex.lock()
	results_data["integer"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()

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
	
	mutex.lock()
	results_data["float"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()

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
	
	mutex.lock()
	results_data["vector"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()

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
	
	mutex.lock()
	results_data["string"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()
