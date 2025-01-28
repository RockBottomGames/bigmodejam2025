@tool
extends Node2D
class_name MirroredRayCast2D

@onready var ray_cast_2d_pos: OffsetRayCast2D = %RayCast2DPos
@onready var ray_cast_2d_neg: OffsetRayCast2D = %RayCast2DNeg

@export var initial_raycast: OffsetRayCast2D = null:
	get:
		return initial_raycast
	set(value):
		initial_raycast = value
		if ray_cast_2d_pos != null:
			reset_raycasts()

func reset_raycasts() -> void:
	if initial_raycast == null:
		return
	
	ray_cast_2d_pos.tip_offset = initial_raycast.tip_offset
	ray_cast_2d_neg.tip_offset = initial_raycast.tip_offset
	
	ray_cast_2d_pos.length = initial_raycast.length
	ray_cast_2d_neg.length = initial_raycast.length
	
	ray_cast_2d_pos.collision_mask = initial_raycast.collision_mask
	ray_cast_2d_neg.collision_mask = initial_raycast.collision_mask
	
	ray_cast_2d_pos.exclude_parent = initial_raycast.exclude_parent
	ray_cast_2d_neg.exclude_parent = initial_raycast.exclude_parent
	
	ray_cast_2d_pos.hit_from_inside = initial_raycast.hit_from_inside
	ray_cast_2d_neg.hit_from_inside = initial_raycast.hit_from_inside
	
	ray_cast_2d_pos.collide_with_areas = initial_raycast.collide_with_areas
	ray_cast_2d_neg.collide_with_areas = initial_raycast.collide_with_areas
	
	ray_cast_2d_pos.collide_with_bodies = initial_raycast.collide_with_bodies
	ray_cast_2d_neg.collide_with_bodies = initial_raycast.collide_with_bodies

@export var angle_degrees: float = 1.0:
	get:
		return angle_degrees
	set(value):
		if angle_degrees != value:
			angle_degrees = value
			if ray_cast_2d_pos != null:
				_update_ray_angles()

func _update_ray_angles() -> void:
	ray_cast_2d_pos.rotation = deg_to_rad(angle_degrees)
	ray_cast_2d_neg.rotation = -deg_to_rad(angle_degrees)

func _find_closer_collision_raycast(raycast_a: OffsetRayCast2D, raycast_b: OffsetRayCast2D) -> OffsetRayCast2D:
	if !raycast_a.is_colliding_with_offset() and !raycast_b.is_colliding_with_offset():
		return null
	if !raycast_a.is_colliding_with_offset() and raycast_b.is_colliding_with_offset():
		return raycast_b
	if raycast_a.is_colliding_with_offset() and !raycast_b.is_colliding_with_offset():
		return raycast_a
	var length_a: float = raycast_a.get_collision_point().length()
	var length_b: float = raycast_b.get_collision_point().length()
	if length_a <= length_b:
		return raycast_a
	return raycast_b

func get_colliding_raycast() -> OffsetRayCast2D:
	return _find_closer_collision_raycast(ray_cast_2d_pos, ray_cast_2d_neg)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset_raycasts()
	_update_ray_angles()
