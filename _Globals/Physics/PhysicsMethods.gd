extends Node

func apply_central_impulse_to_velocity(inital_velocity: Vector2, impulse: Vector2) -> Vector2:
	return inital_velocity + impulse
	
func apply_central_force_to_velocity(inital_velocity: Vector2, force: Vector2, mass: float, delta: float) -> Vector2:
	return inital_velocity + (force * (delta / mass))
