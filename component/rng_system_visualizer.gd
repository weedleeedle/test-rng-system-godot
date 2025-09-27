@tool
class_name RngSystemVisualizer extends Control

@export var rng_system: RNGSystem:
	get:
		return rng_system
	set(value):
		rng_system = value
		update_display()

@export var stat: float:
	get:
		return stat
	set(value):
		stat = value	
		update_display()

@export var num_samples: int:
	get:
		return num_samples
	set(value):
		num_samples = value
		update_display()
		
# How many points to plot along the curve.
@export var resolution: int:
	get:
		return resolution
	set(value):
		resolution = value
		update_display()

@onready var line: Line2D = $Line2D

# Tracks max and min values and the results of each sample.
class SampleDistribution: 
	var min_value: float
	var max_value: float
	var samples: Array[float] = []

	func add_sample(sample: float) -> void:
		# This is our first sample, so we set the min and max values.
		if samples.is_empty():
			min_value = sample
			max_value = sample

		min_value = min(min_value, sample)
		max_value = max(max_value, sample)
		samples.push_back(sample)

class Histogram:
	var min_value: float
	var max_value: float
	var max_count: float = 0.0
	var bucket_width: float
	var num_buckets: int

	var bucket_counts: Array[int]

	func _init(p_min_value: float, p_max_value: float, p_num_buckets: int) -> void:
		min_value = p_min_value
		max_value = p_max_value
		num_buckets = p_num_buckets
		bucket_width = (max_value - min_value) / float(num_buckets)
		for i in range(num_buckets):
			bucket_counts.push_back(0)


	func add_sample(sample: float) -> void:
		# Find out which bucket to increment the count of.
		var bucket = floori((sample - min_value) / bucket_width)
		# Listen, idk man
		if bucket == num_buckets:
			bucket -= 1
		bucket_counts[bucket] += 1
		max_count = max(bucket_counts[bucket], max_count)

func update_display() -> void:
	line.clear_points()
	var distribution = await generate_distribution(rng_system, stat, num_samples)
	var histogram = await generate_histogram(distribution)
	if line:
		await render_histogram(histogram)

func render_histogram(p_histogram: Histogram) -> void:
	line.clear_points()
	var graph_height = p_histogram.max_count
	var graph_width = p_histogram.bucket_counts.size()
	for i in range(p_histogram.bucket_counts.size()):
		var x = float(i) / graph_width * size.x
		var y = size.y - p_histogram.bucket_counts[i] / graph_height * size.y
		line.add_point(Vector2(x, y))

func generate_histogram(p_distribution: SampleDistribution) -> Histogram:
	var histogram = Histogram.new(p_distribution.min_value, p_distribution.max_value, resolution)
	for sample in p_distribution.samples:
		histogram.add_sample(sample)
	return histogram

func generate_distribution(p_rng_system: RNGSystem, p_stat: float, p_num_samples: float) -> SampleDistribution:
	var distribution := SampleDistribution.new()
	for i in range(p_num_samples):
		distribution.add_sample(p_rng_system.roll(p_stat))

	return distribution
