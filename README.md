# Godot Static Typing Performance Benchmark

![Godot Version](https://img.shields.io/badge/Godot-4.4.rc2-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Overview

This repository contains a performance benchmark tool for Godot 4.4.rc2 that measures the impact of static typing on GDScript performance. The benchmark compares execution speeds between typed and untyped variables for various data types, providing detailed metrics on performance improvements.

## Features

- Comprehensive benchmarking of four primary data types:
  - Integers
  - Floats
  - Vectors (Vector2)
  - Strings
- Visual real-time progress tracking
- Detailed performance reports with colored indicators
- Multithreaded testing for accurate measurement
- Proper warmup phase to eliminate JIT compilation variance

## Results

The benchmark measures performance differences between variables with explicit type annotations (static typing) and variables without type annotations (dynamic typing). Results typically show:

- Integer operations: Performance improvements of 5-15%
- Float operations: Performance improvements of 5-15%
- Vector operations: Performance improvements of 10-20%
- String operations: Performance improvements of 5-15%

Actual results will vary based on hardware, OS, and specific Godot version.

## How It Works

The benchmark:

1. Runs a warmup phase to stabilize JIT compiler behavior
2. Performs identical operations on typed and untyped variables
3. Times the execution of millions of iterations for each test
4. Calculates performance differences and operations per second
5. Generates a detailed report with colored performance indicators

## Technical Details

### Test Methodology

Each test performs millions of iterations (default: 25,000,000) of common operations on both typed and untyped variables:

- **Integer Test**: Addition, multiplication, and division operations
- **Float Test**: Addition, multiplication, and division with floating point values
- **Vector Test**: Vector addition, multiplication, normalization, and distance calculations
- **String Test**: String creation, concatenation, and substring operations

### Threading

The benchmark utilizes Godot's threading system to ensure UI responsiveness during the intensive tests. A mutex is used to safely update progress and results between threads.

## Usage

1. Open the project in Godot 4.4.rc2 or higher
2. Run the benchmark scene
3. Wait for all tests to complete (may take a few minutes depending on hardware)
4. Review the detailed results

## Why Static Typing Matters

Static typing in GDScript provides several benefits:

- **Performance**: The Godot engine can optimize code better when it knows variable types in advance
- **Code Quality**: Catches type-related errors at compile time rather than runtime
- **Better IDE Support**: Enables more accurate autocompletion and suggestions
- **Self-Documentation**: Makes code more readable by explicitly stating expected types

## Contributing

Contributions are welcome! Feel free to:

- Report bugs or issues
- Suggest additional tests or improvements
- Submit pull requests with enhancements

## License

This project is licensed under the MIT License - see the LICENSE file for details.