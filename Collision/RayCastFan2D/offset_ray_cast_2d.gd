@tool
extends RayCast2D
class_name OffsetRayCast2D

@export var tip_offset: float = 5.0:
	get:
		return tip_offset
	set(value):
		if tip_offset != value:
			tip_offset = value
			_update_ray_tip_offset()

@export var length: float = 50.0:
	get:
		return length
	set(value):
		if length != value:
			length = value
			_update_ray_length()

func _update_ray_tip_offset() -> void:
	pass

func _update_ray_length() -> void:
	target_position = Vector2(length, 0)

func is_colliding_with_offset() -> bool:
	var collider: Node2D = get_collider()
	return is_colliding() and (to_local(collider.global_position).length() < (length - tip_offset))

func _ready() -> void:
	_update_ray_tip_offset()
	_update_ray_length()
