extends SpringObjectData
class_name SpringDataGlobalPosition2D

var _global_position: Vector2 = Vector2.ZERO

func get_velocity() -> Vector2:
	return Vector2.ZERO

func set_velocity(new_velocity: Vector2) -> void:
	pass

func get_mass() -> float:
	return 1.0

func set_mass(new_mass: float) -> void:
	pass

func get_global_position() -> Vector2:
	return _global_position

func _init(
	global_position_: Vector2 = Vector2.ZERO,
	target_: SpringObjectData = null
):
	super(null, target_)
	_global_position = global_position_
