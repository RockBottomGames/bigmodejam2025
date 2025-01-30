extends Resource
class_name SpringData

@export var spring_constant: float = 0.0 # typically ~3 - 10000
@export var damping_coefficient: float = 0.0 # typically 0 - 0.5
@export var equilibrium_distance: float = 0.0

func _init(
	spring_constant_: float = 0.0, # typically ~3 - 10000
	damping_coefficient_: float = 0.0, # typically 0 - 0.5
	equilibrium_distance_: float = 0.0,
):
	spring_constant = spring_constant_
	damping_coefficient = damping_coefficient_
	equilibrium_distance = equilibrium_distance_

func calculate_equilibrium_displacement(local_spring_vector: Vector2) -> Vector2:
	var equilibrium_displacement = Vector2(equilibrium_distance - local_spring_vector.length(), 0).rotated(local_spring_vector.angle())
	return equilibrium_displacement

func calculate_spring_force(local_spring_vector: Vector2) -> Vector2:
	return -spring_constant * calculate_equilibrium_displacement(local_spring_vector)
	
func calculate_damp_force(velocity: Vector2, local_spring_vector: Vector2) -> Vector2:
	return -damping_coefficient * velocity.project(local_spring_vector)
