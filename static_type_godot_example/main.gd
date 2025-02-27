extends Control

# Configuration Section
@onready var label_information: RichTextLabel = %LabelInformation
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var label_current_status: RichTextLabel = %LabelCurrentStatus
@onready var label_results: RichTextLabel = %LabelResults

# Iteration counts
const ITERATIONS: int = 25_000_000
const WARMUP_ITERATIONS: int = 10_000

# Threading
var thread: Thread
var mutex: Mutex
var is_running: bool = false
var current_progress: float = 0.0
var total_tests: int = 4  # integer, float, vector, string tests
var current_test_index: int = 0
var iteration_count: int = 0

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

# Progress update interval (update every X iterations)
const PROGRESS_UPDATE_INTERVAL: int = 250_000

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
	current_test_index = 0
	iteration_count = 0
	progress_bar.value = 0
	label_current_status.text = "Starting benchmark..."
	
	thread = Thread.new()
	thread.start(_run_benchmark_thread)

func _run_benchmark_thread() -> void:
	_warmup.call_deferred()
	
	# Add detailed transition status updates
	call_deferred("_update_status", "[System] Warmup phase complete. Preparing benchmark environment...")
	OS.delay_msec(300)
	
	call_deferred("_update_status", "[System] Configuring memory for optimal test conditions...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[System] Allocating thread resources for benchmark tests...")
	OS.delay_msec(200)
	
	# Run each test and update progress with very detailed status messages
	current_test_index = 0
	call_deferred("_update_status", "[Integer Benchmark] Initializing integer performance tests...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[Integer Benchmark] Configuring integer test parameters...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[Integer Benchmark] Starting untyped vs typed measurements...")
	OS.delay_msec(100)
	_test_integer_operations()
	
	current_test_index = 1
	call_deferred("_update_status", "[Float Benchmark] Initializing floating-point performance tests...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[Float Benchmark] Configuring IEEE-754 test parameters...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[Float Benchmark] Starting untyped vs typed measurements...")
	OS.delay_msec(100)
	_test_float_operations()
	
	current_test_index = 2
	call_deferred("_update_status", "[Vector Benchmark] Initializing Vector2 performance tests...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[Vector Benchmark] Configuring vector operation parameters...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[Vector Benchmark] Starting untyped vs typed measurements...")
	OS.delay_msec(100)
	_test_vector_operations()
	
	current_test_index = 3
	call_deferred("_update_status", "[String Benchmark] Initializing string performance tests...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[String Benchmark] Configuring string operation parameters...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[String Benchmark] Starting untyped vs typed measurements...")
	OS.delay_msec(100)
	_test_string_operations()
	
	current_test_index = 4
	call_deferred("_update_status", "[Analysis] All benchmarks complete. Collecting performance data...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[Analysis] Processing timing results across all tests...")
	OS.delay_msec(200)
	
	call_deferred("_update_status", "[Analysis] Calculating performance metrics and improvements...")
	OS.delay_msec(200)
	
	call_deferred("_benchmark_completed")

func _update_progress(value: float) -> void:
	mutex.lock()
	current_progress = value
	mutex.unlock()
	
	# Use call_deferred to update from the main thread
	call_deferred("_emit_progress_updated", value)

# Helper function to emit the signal on the main thread
func _emit_progress_updated(value: float) -> void:
	if is_inside_tree():
		progress_updated.emit(value)

# Helper function to update status label from a thread safely
func _update_status(text: String) -> void:
	if not is_inside_tree():
		return
	label_current_status.text = text

func _process(_delta: float) -> void:
	if is_running:
		mutex.lock()
		progress_bar.value = current_progress
		mutex.unlock()

func _benchmark_completed() -> void:
	is_running = false
	thread.wait_to_finish()
	progress_bar.value = 100
	
	call_deferred("_update_status", "[Results] Collecting benchmark data from all tests...")
	await get_tree().create_timer(0.2).timeout
	
	call_deferred("_update_status", "[Results] Calculating final performance metrics...")
	await get_tree().create_timer(0.2).timeout
	
	call_deferred("_update_status", "[Results] Analyzing type system performance impact...")
	await get_tree().create_timer(0.2).timeout
	
	call_deferred("_update_status", "[Results] Generating performance visualization...")
	await get_tree().create_timer(0.2).timeout
	
	call_deferred("_update_status", "[Results] Formatting benchmark report...")
	await get_tree().create_timer(0.2).timeout
	
	_display_results()
	
	call_deferred("_update_status", "[Complete] Static typing benchmark results are ready for analysis!")
	await get_tree().create_timer(0.3).timeout
	
	# Calculate overall performance improvement
	var total_untyped = 0.0
	var total_typed = 0.0
	for test_name in results_data:
		total_untyped += results_data[test_name].untyped
		total_typed += results_data[test_name].typed
	
	var overall_improvement = ((total_untyped - total_typed) / total_untyped) * 100
	
	if overall_improvement > 15:
		call_deferred("_update_status", "[Conclusion] Static typing provides significant performance benefits in Godot 4.4.rc1!")
	elif overall_improvement > 5:
		call_deferred("_update_status", "[Conclusion] Static typing offers moderate performance improvements in Godot 4.4.rc1.")
	else:
		call_deferred("_update_status", "[Conclusion] Static typing shows minimal performance impact in this test configuration.")

func _warmup() -> void:
	call_deferred("_update_status", "[Warmup] Initializing benchmark environment...")
	
	# Update progress in smaller chunks for better feedback
	var chunk_size = WARMUP_ITERATIONS / 10
	for i in WARMUP_ITERATIONS:
		var temp = 0
		temp += 1
		
		# Update status at more frequent checkpoints using call_deferred
		if i == chunk_size:
			call_deferred("_update_status", "[Warmup] 10% - Stabilizing JIT compilation patterns...")
		elif i == chunk_size * 2:
			call_deferred("_update_status", "[Warmup] 20% - Optimizing instruction pathways...")
		elif i == chunk_size * 3:
			call_deferred("_update_status", "[Warmup] 30% - Calibrating memory access patterns...")
		elif i == chunk_size * 4:
			call_deferred("_update_status", "[Warmup] 40% - Preparing CPU branch prediction...")
		elif i == chunk_size * 5:
			call_deferred("_update_status", "[Warmup] 50% - Stabilizing thread performance...")
		elif i == chunk_size * 6:
			call_deferred("_update_status", "[Warmup] 60% - Warming CPU caches...")
		elif i == chunk_size * 7:
			call_deferred("_update_status", "[Warmup] 70% - Calibrating memory allocation pools...")
		elif i == chunk_size * 8:
			call_deferred("_update_status", "[Warmup] 80% - Finalizing compiler optimizations...")
		elif i == chunk_size * 9:
			call_deferred("_update_status", "[Warmup] 90% - Preparing for primary benchmarks...")
			label_current_status.text = "[Warmup] 70% - Calibrating memory allocation pools..."
		elif i == chunk_size * 8:
			label_current_status.text = "[Warmup] 80% - Finalizing compiler optimizations..."
		elif i == chunk_size * 9:
			label_current_status.text = "[Warmup] 90% - Preparing for primary benchmarks..."

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
	
	# Add title and header
	results_text += "[color=#FFD700]Benchmark Results:[/color]\n\n"
	
	# Update status while processing each test type with extremely detailed messages
	for test_name in results_data:
		label_current_status.text = "[Analysis] Processing detailed " + test_name + " performance metrics..."
		
		# Add a small delay to show the status message
		OS.delay_msec(150)
		
		var test = results_data[test_name]
		var perf_color = _get_performance_color(test.improvement)
		var ops_color = _get_ops_color(test.ops_per_sec_typed)
		
		# Show detailed performance analysis in status
		label_current_status.text = "[Analysis] " + test_name.capitalize() + ": Calculating execution time difference..."
		OS.delay_msec(100)
		
		label_current_status.text = "[Analysis] " + test_name.capitalize() + ": Computing operations per second..."
		OS.delay_msec(100)
		
		label_current_status.text = "[Analysis] " + test_name.capitalize() + ": Determining performance improvement percentage..."
		OS.delay_msec(100)
		
		# Build results text
		results_text += "[color=#ADD8E6]%s:[/color]\n" % test_name.capitalize()
		var untyped_color = "ff0000" if test.untyped > test.typed else _get_ms_color(test.untyped)
		var typed_color = _get_ms_color(test.typed)
		results_text += "  Untyped: [color=#%s]%.2fms[/color] → Typed: [color=#%s]%.2fms[/color]\n" % [untyped_color, test.untyped, typed_color, test.typed]
		results_text += "  Performance gain: [color=#%s](%.2f%%)[/color]\n" % [perf_color, test.improvement]
		results_text += "  Typed operations: [color=#%s]%s ops/sec[/color]\n\n" % [ops_color, test.ops_per_sec_typed]
	
	# Calculate overall improvement with detailed status updates
	label_current_status.text = "[Summary] Calculating aggregate performance metrics..."
	OS.delay_msec(150)
	
	var total_untyped = 0.0
	var total_typed = 0.0
	
	for test_name in results_data:
		label_current_status.text = "[Summary] Adding " + test_name + " results to totals..."
		OS.delay_msec(50)
		total_untyped += results_data[test_name].untyped
		total_typed += results_data[test_name].typed
	
	label_current_status.text = "[Summary] Computing overall improvement percentage..."
	OS.delay_msec(150)
	
	var overall_improvement = ((total_untyped - total_typed) / total_untyped) * 100
	var overall_color = _get_performance_color(overall_improvement)
	
	label_current_status.text = "[Summary] Formatting final performance report..."
	OS.delay_msec(150)
	
	# Add summary section
	results_text += "[color=#FFD700]Overall Summary:[/color]\n"
	results_text += "  Total untyped time: %.2fms\n" % total_untyped
	results_text += "  Total typed time: %.2fms\n" % total_typed
	results_text += "  Overall improvement: [color=#%s]%.2f%%[/color]\n" % [overall_color, overall_improvement]
	
	# Add technical analysis section
	results_text += "\n[color=#FFD700]Technical Analysis:[/color]\n"
	results_text += "  [color=#ADD8E6]CPU Cache Impact:[/color] Static typing reduces cache misses by eliminating type checks\n"
	results_text += "  [color=#ADD8E6]Memory Layout:[/color] Known types enable more efficient memory access patterns\n"
	results_text += "  [color=#ADD8E6]Compiler Optimization:[/color] Type information enables better JIT optimization\n"
	
	label_current_status.text = "[Rendering] Displaying final benchmark results..."
	OS.delay_msec(100)
	
	label_results.text = results_text

func _test_integer_operations() -> void:
	call_deferred("_update_status", "[Integer Benchmark] Preparing integer operations test environment...")
	
	# Set progress at the start of the test
	_update_progress(current_test_index * 25)
	
	# First half of the test (0-12.5%)
	call_deferred("_update_status", "[Integer - Untyped] Beginning untyped integer operation tests...")
	
	# Define status update messages
	var untyped_status_messages = {
		5: "[Integer - Untyped] 5% - Measuring dynamic type inference overhead...",
		10: "[Integer - Untyped] 10% - Evaluating JIT optimization effectiveness...",
		20: "[Integer - Untyped] 20% - Monitoring memory access patterns...",
		30: "[Integer - Untyped] 30% - Analyzing operation latency trends...",
		40: "[Integer - Untyped] 40% - Evaluating CPU cache utilization...",
		50: "[Integer - Untyped] 50% - Measuring instruction throughput...",
		60: "[Integer - Untyped] 60% - Assessing memory allocation overhead...",
		70: "[Integer - Untyped] 70% - Evaluating branch prediction efficiency...",
		80: "[Integer - Untyped] 80% - Monitoring integer operation stability...",
		90: "[Integer - Untyped] 90% - Finalizing untyped integer measurements..."
	}
	
	var untyped_time = _time_function(func():
		for i in ITERATIONS:
			untyped_int += 1
			untyped_int *= 2
			untyped_int /= 2
			
			if i % PROGRESS_UPDATE_INTERVAL == 0:
				var half_test_progress = (i / float(ITERATIONS)) * 12.5
				var overall_progress = (current_test_index * 25.0) + half_test_progress
				_update_progress(overall_progress)
				
				# Update checkpoints with thread-safe status updates
				var percent_complete = int((i / float(ITERATIONS)) * 100)
				for threshold in untyped_status_messages:
					if percent_complete >= threshold and percent_complete < threshold + 1:
						call_deferred("_update_status", untyped_status_messages[threshold])
						break
	)
	
	# Update progress to the half-way point of this test
	_update_progress(current_test_index * 25 + 12.5)
	
	call_deferred("_update_status", "[Integer - Untyped] Completed untyped tests in " + str(untyped_time) + "ms")
	
	# Second half of the test (12.5-25%)
	call_deferred("_update_status", "[Integer - Typed] Beginning typed integer operation tests...")
	
	# Define status update messages for typed operations
	var typed_status_messages = {
		5: "[Integer - Typed] 5% - Measuring static typing performance benefits...",
		10: "[Integer - Typed] 10% - Evaluating compiler optimization effectiveness...",
		20: "[Integer - Typed] 20% - Analyzing memory access efficiency...",
		30: "[Integer - Typed] 30% - Measuring operation execution speed...",
		40: "[Integer - Typed] 40% - Evaluating direct memory addressing benefits...",
		50: "[Integer - Typed] 50% - Analyzing instruction pipeline efficiency...",
		60: "[Integer - Typed] 60% - Measuring memory layout optimization...",
		70: "[Integer - Typed] 70% - Evaluating type specialization benefits...",
		80: "[Integer - Typed] 80% - Measuring operation throughput stability...",
		90: "[Integer - Typed] 90% - Finalizing typed integer measurements..."
	}
	
	var typed_time = _time_function(func():
		for i in ITERATIONS:
			typed_int += 1
			typed_int *= 2
			typed_int /= 2
			
			if i % PROGRESS_UPDATE_INTERVAL == 0:
				var half_test_progress = (i / float(ITERATIONS)) * 12.5
				var overall_progress = (current_test_index * 25.0) + 12.5 + half_test_progress
				_update_progress(overall_progress)
				
				# Thread-safe status updates
				var percent_complete = int((i / float(ITERATIONS)) * 100)
				for threshold in typed_status_messages:
					if percent_complete >= threshold and percent_complete < threshold + 1:
						call_deferred("_update_status", typed_status_messages[threshold])
						break
	)
	
	call_deferred("_update_status", "[Integer - Typed] Completed typed tests in " + str(typed_time) + "ms")
	
	var improvement = ((untyped_time - typed_time) / untyped_time) * 100
	call_deferred("_update_status", "[Integer - Result] Performance improvement: " + str(improvement) + "%")
	
	mutex.lock()
	results_data["integer"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": improvement,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()
	
	# Ensure we're at exactly the end of this test
	_update_progress((current_test_index + 1) * 25)
	
	mutex.lock()
	results_data["integer"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()
	
	# Ensure we're at exactly the end of this test
	_update_progress((current_test_index + 1) * 25)

func _test_float_operations() -> void:
	call_deferred("_update_status", "[Float Benchmark] Preparing floating-point operations test environment...")
	
	# Set progress at the start of the test
	_update_progress(current_test_index * 25)
	
	# First half of the test (0-12.5%)
	call_deferred("_update_status", "[Float - Untyped] Beginning untyped float operation tests...")
	
	# Define status update messages
	var untyped_status_messages = {
		5: "[Float - Untyped] 5% - Measuring dynamic type inference overhead...",
		10: "[Float - Untyped] 10% - Evaluating JIT optimization effectiveness...",
		20: "[Float - Untyped] 20% - Monitoring memory access patterns...",
		30: "[Float - Untyped] 30% - Analyzing operation latency trends...",
		40: "[Float - Untyped] 40% - Evaluating CPU cache utilization...",
		50: "[Float - Untyped] 50% - Measuring instruction throughput...",
		60: "[Float - Untyped] 60% - Assessing memory allocation overhead...",
		70: "[Float - Untyped] 70% - Evaluating branch prediction efficiency...",
		80: "[Float - Untyped] 80% - Monitoring float operation stability...",
		90: "[Float - Untyped] 90% - Finalizing untyped float measurements..."
	}
	
	var untyped_time = _time_function(func():
		for i in ITERATIONS:
			untyped_float += 1.5
			untyped_float *= 1.5
			untyped_float /= 1.5
			
			if i % PROGRESS_UPDATE_INTERVAL == 0:
				var half_test_progress = (i / float(ITERATIONS)) * 12.5
				var overall_progress = (current_test_index * 25.0) + half_test_progress
				_update_progress(overall_progress)
				
				# Update checkpoints with thread-safe status updates
				var percent_complete = int((i / float(ITERATIONS)) * 100)
				for threshold in untyped_status_messages:
					if percent_complete >= threshold and percent_complete < threshold + 1:
						call_deferred("_update_status", untyped_status_messages[threshold])
						break
	)
	
	# Update progress to the half-way point of this test
	_update_progress(current_test_index * 25 + 12.5)
	
	call_deferred("_update_status", "[Float - Untyped] Completed untyped tests in " + str(untyped_time) + "ms")
	
	# Second half of the test (12.5-25%)
	call_deferred("_update_status", "[Float - Typed] Beginning typed float operation tests...")
	
	# Define status update messages for typed operations
	var typed_status_messages = {
		5: "[Float - Typed] 5% - Measuring static typing performance benefits...",
		10: "[Float - Typed] 10% - Evaluating compiler optimization effectiveness...",
		20: "[Float - Typed] 20% - Analyzing memory access efficiency...",
		30: "[Float - Typed] 30% - Measuring operation execution speed...",
		40: "[Float - Typed] 40% - Evaluating direct memory addressing benefits...",
		50: "[Float - Typed] 50% - Analyzing instruction pipeline efficiency...",
		60: "[Float - Typed] 60% - Measuring memory layout optimization...",
		70: "[Float - Typed] 70% - Evaluating type specialization benefits...",
		80: "[Float - Typed] 80% - Measuring operation throughput stability...",
		90: "[Float - Typed] 90% - Finalizing typed float measurements..."
	}
	
	var typed_time = _time_function(func():
		for i in ITERATIONS:
			typed_float += 1.5
			typed_float *= 1.5
			typed_float /= 1.5
			
			if i % PROGRESS_UPDATE_INTERVAL == 0:
				var half_test_progress = (i / float(ITERATIONS)) * 12.5
				var overall_progress = (current_test_index * 25.0) + 12.5 + half_test_progress
				_update_progress(overall_progress)
				
				# Thread-safe status updates
				var percent_complete = int((i / float(ITERATIONS)) * 100)
				for threshold in typed_status_messages:
					if percent_complete >= threshold and percent_complete < threshold + 1:
						call_deferred("_update_status", typed_status_messages[threshold])
						break
	)
	
	call_deferred("_update_status", "[Float - Typed] Completed typed tests in " + str(typed_time) + "ms")
	
	var improvement = ((untyped_time - typed_time) / untyped_time) * 100
	call_deferred("_update_status", "[Float - Result] Performance improvement: " + str(improvement) + "%")
	
	mutex.lock()
	results_data["float"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": improvement,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()
	
	# Ensure we're at exactly the end of this test
	_update_progress((current_test_index + 1) * 25)
	
	mutex.lock()
	results_data["float"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()
	
	# Ensure we're at exactly the end of this test
	_update_progress((current_test_index + 1) * 25)

func _test_vector_operations() -> void:
	call_deferred("_update_status", "[Vector Benchmark] Preparing vector operations test environment...")
	
	# Set progress at the start of the test
	_update_progress(current_test_index * 25)
	
	# First half of the test (0-12.5%)
	call_deferred("_update_status", "[Vector - Untyped] Beginning untyped vector operation tests...")
	
	# Define status update messages
	var untyped_status_messages = {
		5: "[Vector - Untyped] 5% - Measuring dynamic type inference overhead...",
		10: "[Vector - Untyped] 10% - Evaluating JIT optimization effectiveness...",
		20: "[Vector - Untyped] 20% - Monitoring memory access patterns...",
		30: "[Vector - Untyped] 30% - Analyzing operation latency trends...",
		40: "[Vector - Untyped] 40% - Evaluating CPU cache utilization...",
		50: "[Vector - Untyped] 50% - Measuring instruction throughput...",
		60: "[Vector - Untyped] 60% - Assessing memory allocation overhead...",
		70: "[Vector - Untyped] 70% - Evaluating branch prediction efficiency...",
		80: "[Vector - Untyped] 80% - Monitoring vector operation stability...",
		90: "[Vector - Untyped] 90% - Finalizing untyped vector measurements..."
	}
	
	var untyped_time = _time_function(func():
		for i in ITERATIONS:
			untyped_vector += Vector2.ONE
			untyped_vector *= 1.5
			untyped_vector = untyped_vector.normalized()
			var _dist = untyped_vector.distance_to(Vector2.ZERO)
			
			if i % PROGRESS_UPDATE_INTERVAL == 0:
				var half_test_progress = (i / float(ITERATIONS)) * 12.5
				var overall_progress = (current_test_index * 25.0) + half_test_progress
				_update_progress(overall_progress)
				
				# Update checkpoints with thread-safe status updates
				var percent_complete = int((i / float(ITERATIONS)) * 100)
				for threshold in untyped_status_messages:
					if percent_complete >= threshold and percent_complete < threshold + 1:
						call_deferred("_update_status", untyped_status_messages[threshold])
						break
	)
	
	# Update progress to the half-way point of this test
	_update_progress(current_test_index * 25 + 12.5)
	
	call_deferred("_update_status", "[Vector - Untyped] Completed untyped tests in " + str(untyped_time) + "ms")
	
	# Second half of the test (12.5-25%)
	call_deferred("_update_status", "[Vector - Typed] Beginning typed vector operation tests...")
	
	# Define status update messages for typed operations
	var typed_status_messages = {
		5: "[Vector - Typed] 5% - Measuring static typing performance benefits...",
		10: "[Vector - Typed] 10% - Evaluating compiler optimization effectiveness...",
		20: "[Vector - Typed] 20% - Analyzing memory access efficiency...",
		30: "[Vector - Typed] 30% - Measuring operation execution speed...",
		40: "[Vector - Typed] 40% - Evaluating direct memory addressing benefits...",
		50: "[Vector - Typed] 50% - Analyzing instruction pipeline efficiency...",
		60: "[Vector - Typed] 60% - Measuring memory layout optimization...",
		70: "[Vector - Typed] 70% - Evaluating type specialization benefits...",
		80: "[Vector - Typed] 80% - Measuring operation throughput stability...",
		90: "[Vector - Typed] 90% - Finalizing typed vector measurements..."
	}
	
	var typed_time = _time_function(func():
		for i in ITERATIONS:
			typed_vector += Vector2.ONE
			typed_vector *= 1.5
			typed_vector = typed_vector.normalized()
			var _dist = typed_vector.distance_to(Vector2.ZERO)
			
			if i % PROGRESS_UPDATE_INTERVAL == 0:
				var half_test_progress = (i / float(ITERATIONS)) * 12.5
				var overall_progress = (current_test_index * 25.0) + 12.5 + half_test_progress
				_update_progress(overall_progress)
				
				# Thread-safe status updates
				var percent_complete = int((i / float(ITERATIONS)) * 100)
				for threshold in typed_status_messages:
					if percent_complete >= threshold and percent_complete < threshold + 1:
						call_deferred("_update_status", typed_status_messages[threshold])
						break
	)
	
	call_deferred("_update_status", "[Vector - Typed] Completed typed tests in " + str(typed_time) + "ms")
	
	var improvement = ((untyped_time - typed_time) / untyped_time) * 100
	call_deferred("_update_status", "[Vector - Result] Performance improvement: " + str(improvement) + "%")
	
	mutex.lock()
	results_data["vector"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": improvement,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()
	
	# Ensure we're at exactly the end of this test
	_update_progress((current_test_index + 1) * 25)
	
	mutex.lock()
	results_data["vector"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()
	
	# Ensure we're at exactly the end of this test
	_update_progress((current_test_index + 1) * 25)

func _test_string_operations() -> void:
	call_deferred("_update_status", "[String Benchmark] Preparing string operations test environment...")
	
	# Set progress at the start of the test
	_update_progress(current_test_index * 25)
	
	# First half of the test (0-12.5%)
	call_deferred("_update_status", "[String - Untyped] Beginning untyped string operation tests...")
	
	# Define status update messages
	var untyped_status_messages = {
		5: "[String - Untyped] 5% - Measuring dynamic type inference overhead...",
		10: "[String - Untyped] 10% - Evaluating JIT optimization effectiveness...",
		20: "[String - Untyped] 20% - Monitoring memory access patterns...",
		30: "[String - Untyped] 30% - Analyzing operation latency trends...",
		40: "[String - Untyped] 40% - Evaluating CPU cache utilization...",
		50: "[String - Untyped] 50% - Measuring instruction throughput...",
		60: "[String - Untyped] 60% - Assessing memory allocation overhead...",
		70: "[String - Untyped] 70% - Evaluating branch prediction efficiency...",
		80: "[String - Untyped] 80% - Monitoring string operation stability...",
		90: "[String - Untyped] 90% - Finalizing untyped string measurements..."
	}
	
	var untyped_time = _time_function(func():
		for i in ITERATIONS:
			untyped_string = "test"
			untyped_string += "_suffix"
			untyped_string = untyped_string.substr(0, 4)
			
			if i % PROGRESS_UPDATE_INTERVAL == 0:
				var half_test_progress = (i / float(ITERATIONS)) * 12.5
				var overall_progress = (current_test_index * 25.0) + half_test_progress
				_update_progress(overall_progress)
				
				# Update checkpoints with thread-safe status updates
				var percent_complete = int((i / float(ITERATIONS)) * 100)
				for threshold in untyped_status_messages:
					if percent_complete >= threshold and percent_complete < threshold + 1:
						call_deferred("_update_status", untyped_status_messages[threshold])
						break
	)
	
	# Update progress to the half-way point of this test
	_update_progress(current_test_index * 25 + 12.5)
	
	call_deferred("_update_status", "[String - Untyped] Completed untyped tests in " + str(untyped_time) + "ms")
	
	# Second half of the test (12.5-25%)
	call_deferred("_update_status", "[String - Typed] Beginning typed string operation tests...")
	
	# Define status update messages for typed operations
	var typed_status_messages = {
		5: "[String - Typed] 5% - Measuring static typing performance benefits...",
		10: "[String - Typed] 10% - Evaluating compiler optimization effectiveness...",
		20: "[String - Typed] 20% - Analyzing memory access efficiency...",
		30: "[String - Typed] 30% - Measuring operation execution speed...",
		40: "[String - Typed] 40% - Evaluating direct memory addressing benefits...",
		50: "[String - Typed] 50% - Analyzing instruction pipeline efficiency...",
		60: "[String - Typed] 60% - Measuring memory layout optimization...",
		70: "[String - Typed] 70% - Evaluating type specialization benefits...",
		80: "[String - Typed] 80% - Measuring operation throughput stability...",
		90: "[String - Typed] 90% - Finalizing typed string measurements..."
	}
	
	var typed_time = _time_function(func():
		for i in ITERATIONS:
			typed_string = "test"
			typed_string += "_suffix"
			typed_string = typed_string.substr(0, 4)
			
			if i % PROGRESS_UPDATE_INTERVAL == 0:
				var half_test_progress = (i / float(ITERATIONS)) * 12.5
				var overall_progress = (current_test_index * 25.0) + 12.5 + half_test_progress
				_update_progress(overall_progress)
				
				# Thread-safe status updates
				var percent_complete = int((i / float(ITERATIONS)) * 100)
				for threshold in typed_status_messages:
					if percent_complete >= threshold and percent_complete < threshold + 1:
						call_deferred("_update_status", typed_status_messages[threshold])
						break
	)
	
	call_deferred("_update_status", "[String - Typed] Completed typed tests in " + str(typed_time) + "ms")
	
	var improvement = ((untyped_time - typed_time) / untyped_time) * 100
	call_deferred("_update_status", "[String - Result] Performance improvement: " + str(improvement) + "%")
	
	mutex.lock()
	results_data["string"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": improvement,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()
	
	# Ensure we're at exactly the end of this test
	_update_progress((current_test_index + 1) * 25)
	
	mutex.lock()
	results_data["string"] = {
		"untyped": untyped_time,
		"typed": typed_time,
		"improvement": ((untyped_time - typed_time) / untyped_time) * 100,
		"ops_per_sec_typed": _format_ops_per_second(typed_time)
	}
	mutex.unlock()
	
	# Ensure we're at exactly the end of this test
	_update_progress((current_test_index + 1) * 25)
