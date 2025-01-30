extends SpringObjectData
class_name SpringDataStaticBody2D

var _rigid_object: StaticBody2D = null:
	get:
		return object as StaticBody2D

func get_velocity() -> Vector2:
	return Vector2.ZERO

func set_velocity(new_velocity: Vector2) -> void:
	pass

func get_mass() -> float:
	return 1.0

func set_mass(new_mass: float) -> void:
	pass
