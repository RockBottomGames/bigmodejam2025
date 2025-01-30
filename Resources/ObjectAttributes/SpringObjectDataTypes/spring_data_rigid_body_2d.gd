extends SpringObjectData
class_name SpringDataRigidBody2D

var _rigid_object: RigidBody2D = null:
	get:
		return object as RigidBody2D

func get_velocity() -> Vector2:
	return _rigid_object.linear_velocity

func set_velocity(new_velocity: Vector2) -> void:
	_rigid_object.linear_velocity = new_velocity

func get_mass() -> float:
	return _rigid_object.mass

func set_mass(new_mass: float) -> void:
	_rigid_object.mass = new_mass
