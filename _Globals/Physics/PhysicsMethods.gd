extends Node

func apply_central_impulse_to_velocity(inital_velocity: Vector2, impulse: Vector2) -> Vector2:
	return inital_velocity + impulse
	
func apply_central_force_to_velocity(inital_velocity: Vector2, force: Vector2, mass: float, delta: float) -> Vector2:
	return inital_velocity + (force * (delta / mass))

const _FULL_360 = 2 * PI

func get_closest_angle_to(initial_angle_to: float, angle_from: float) -> float:
	# return a fixed initial_angle_to where it is max PI distance from angle_from
	var new_angle_to = initial_angle_to
	print("before calculate angle")
	print
	while new_angle_to - angle_from <= -PI:
		new_angle_to += _FULL_360
	while new_angle_to - angle_from > PI:
		new_angle_to -= _FULL_360
	print("after calculate angle")
	return new_angle_to
