@tool
extends OffsetRayCast2D
class_name RayCastFan2D

@export var separation_degress: float = 2.0:
	get:
		return separation_degress
	set(value):
		if value != separation_degress:
			separation_degress = value
			if MIRRORED_RAY_CAST_2D != null:
				_update_ray_angles()

@export var mirrored_pair_count: int = 0:
	get:
		return mirrored_pair_count
	set(value):
		if value != mirrored_pair_count:
			mirrored_pair_count = value
			if MIRRORED_RAY_CAST_2D != null:
				_build_mirrored_pairs()

@onready var MIRRORED_RAY_CAST_2D = preload("res://Collision/RayCastFan2D/mirrored_ray_cast_2d.tscn")

var _mirrored_pairs: Array[MirroredRayCast2D] = []
var _mirrored_pairs_pool: Array[MirroredRayCast2D] = []

func _build_mirrored_pairs():
	for prev_pair: MirroredRayCast2D in _mirrored_pairs:
		remove_child(prev_pair)
		_mirrored_pairs_pool.push_back(prev_pair)
	
	_mirrored_pairs.clear()
	
	for index in mirrored_pair_count:
		var mirrored_pair: MirroredRayCast2D = null
		if _mirrored_pairs_pool.is_empty():
			mirrored_pair = MIRRORED_RAY_CAST_2D.instantiate()
			mirrored_pair.initial_raycast = self
			mirrored_pair.angle_degrees = (index + 1) * separation_degress
		else:
			mirrored_pair = _mirrored_pairs_pool.pop_back()
			mirrored_pair.initial_raycast = self
			mirrored_pair.angle_degrees = (index + 1) * separation_degress
			mirrored_pair.reset_raycasts()
		add_child(mirrored_pair)
		_mirrored_pairs.push_back(mirrored_pair)

func _update_ray_angles():
	for index: int in _mirrored_pairs.size():
		var mirrored_pair = _mirrored_pairs[index]
		mirrored_pair.angle_degrees = (index + 1) * separation_degress

func _update_ray_length() -> void:
	target_position = Vector2(length, 0)
	for mirrored_pair: MirroredRayCast2D in _mirrored_pairs:
		mirrored_pair.reset_raycasts()

func _update_ray_tip_offset() -> void:
	for mirrored_pair: MirroredRayCast2D in _mirrored_pairs:
		mirrored_pair.reset_raycasts()

func get_colliding_raycast() -> OffsetRayCast2D:
	if is_colliding_with_offset():
		return self
	for index: int in _mirrored_pairs.size():
		var mirrored_pair = _mirrored_pairs[index]
		var colliding_raycast = mirrored_pair.get_colliding_raycast()
		if colliding_raycast != null:
			return colliding_raycast
	return null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_build_mirrored_pairs()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
