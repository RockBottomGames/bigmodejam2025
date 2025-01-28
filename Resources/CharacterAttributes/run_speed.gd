extends Resource
class_name RunSpeed

@export var top_speed: float = 0.0
@export var acceleration: float = 0.0
@export var slow_percent: float = 1.0
@export var turn_percent: float = 1.0

func calculate_speed_delta_run(delta: float, direction: float) -> float:
	return direction * acceleration * delta

func calculate_speed_delta_slow(delta: float, direction: float) -> float:
	return direction * acceleration * slow_percent * delta

func calculate_speed_delta_turn(delta: float, direction: float) -> float:
	return direction * acceleration * turn_percent * delta

func _init(
	top_speed_: float = 0.0,
	acceleration_: float = 0.0,
	slow_percent_: float = 1.0,
	turn_percent_: float = 1.0
):
	top_speed = top_speed_
	acceleration = acceleration_
	slow_percent = slow_percent_
	turn_percent = turn_percent_
