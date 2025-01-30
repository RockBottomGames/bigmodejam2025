extends SpringObjectData
class_name SpringDataCharacterBody2D

var _character_object: CharacterBody2D = null:
	get:
		return object as CharacterBody2D

func get_velocity() -> Vector2:
	return _character_object.velocity

func set_velocity(new_velocity: Vector2) -> void:
	_character_object.velocity = new_velocity
