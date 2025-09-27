@tool
class_name NormalDistribution extends RNGSystem

@export var deviation: float = 1.0

var rng: RandomNumberGenerator

func _init(p_deviation: float = 1.0) -> void:
	deviation = p_deviation
	rng = RandomNumberGenerator.new()

func roll(stat: float) -> float:
	return rng.randfn(stat, deviation)
