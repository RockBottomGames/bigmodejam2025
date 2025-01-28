extends Resource
class_name SpringData

@export var connection1: SpringObjectData = SpringObjectData.new(1.0, Vector2.ZERO)
@export var connection2: SpringObjectData = SpringObjectData.new(1.0, Vector2.ZERO)
@export var equilibrium_distance: float = 0.0
@export var spring_constant: float = 0.0 # typically ~3 - 10000
@export var damping_coefficient: float = 0.0 # typically 0 - 0.5
@export var local_spring_vector: Vector2 = Vector2.ZERO # Should be connection2 - connection1

func _init(
	connection1_: SpringObjectData = SpringObjectData.new(1.0, Vector2.ZERO),
	connection2_: SpringObjectData = SpringObjectData.new(1.0, Vector2.ZERO),
	equilibrium_distance_: float = 0.0,
	spring_constant_: float = 0.0, # typically ~3 - 10000
	damping_coefficient_: float = 0.0, # typically 0 - 0.5
	local_spring_vector_: Vector2 = Vector2.ZERO # Should be connection2 - connection1
):
	connection1 = connection1_
	connection2 = connection2_
	equilibrium_distance = equilibrium_distance_
	spring_constant = spring_constant_
	damping_coefficient = damping_coefficient_
	local_spring_vector = local_spring_vector_

func _calculate_equilibrium_displacement() -> Vector2:
	local_spring_vector = connection2.position - connection1.position
	var equilibrium_displacement = Vector2(equilibrium_distance - local_spring_vector.length(), 0).rotated(local_spring_vector.angle())
	return equilibrium_displacement

func _calculate_spring_force() -> Vector2:
	return -spring_constant * _calculate_equilibrium_displacement()
	
func _calculate_damp_force_connection1() -> Vector2:
	return -damping_coefficient * connection1.velocity.project(local_spring_vector)
	
func _calculate_damp_force_connection2() -> Vector2:
	return -damping_coefficient * connection2.velocity.project(-local_spring_vector)

func calculate_and_update_connection_velocities(delta: float) -> void:
	var conn1_spring_force: Vector2 = _calculate_spring_force()
	var conn2_spring_force: Vector2 = -conn1_spring_force
	var conn1_damp_force: Vector2 = _calculate_damp_force_connection1()
	var conn2_damp_force: Vector2 = _calculate_damp_force_connection2()
	connection1.applied_force = conn1_spring_force + conn1_damp_force
	connection2.applied_force = conn2_spring_force + conn2_damp_force
	connection1.velocity = PhysicsMethods.apply_central_force_to_velocity(
		connection1.velocity,
		connection1.applied_force,
		connection1.mass,
		delta
	)
	connection2.velocity = PhysicsMethods.apply_central_force_to_velocity(
		connection2.velocity,
		connection2.applied_force,
		connection2.mass,
		delta
	)

class SpringObjectData extends Resource:
	@export var mass: float = 1.0
	@export var position: Vector2 = Vector2.ZERO
	@export var velocity: Vector2 = Vector2.ZERO
	@export var applied_force: Vector2 = Vector2.ZERO
	
	func _init(
		mass_: float = 1.0,
		position_: Vector2 = Vector2.ZERO
	):
		mass = mass_
		position = position_
