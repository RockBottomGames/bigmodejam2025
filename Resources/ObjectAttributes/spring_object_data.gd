extends Node
class_name SpringObjectData

var _mass: float = 1.0
var _velocity: Vector2 = Vector2.ZERO
@export var object: Node2D = null
@export var target: SpringObjectData = null
var _spring: SpringData = null

func _exit_tree() -> void:
	clear()

func clear() -> void:
	object = null
	target = null
	_spring = null

func free() -> void:
	clear()
	super()

func get_velocity() -> Vector2:
	return _velocity

func set_velocity(new_velocity: Vector2) -> void:
	_velocity = new_velocity

func get_mass() -> float:
	return _mass

func set_mass(new_mass: float) -> void:
	_mass = new_mass

func get_global_position() -> Vector2:
	return object.global_position if object != null else Vector2.ZERO

func spring_at_position(global_position: Vector2, new_spring: SpringData) -> void:
	_spring = new_spring 
	relinquish_target()
	target = SpringDataGlobalPosition2D.new(global_position, self)

func attempt_acquire_target(attempted_target: Node2D, new_spring: SpringData) -> bool:
	relinquish_target()
	if attempted_target == null:
		return false
	if attempted_target.has_method("on_spring_attached"):
		target = attempted_target.on_spring_attached(self, new_spring)
		if target != null:
			_spring = new_spring
			return true
		return false
	target = SpringObjectData.new(attempted_target, self)
	_spring = new_spring
	return true
	
func relinquish_target() -> void:
	_spring = null
	if target == null:
		return
	if target.object != null and target.object.has_method("on_spring_relinquished"):
		target.object.on_spring_relinquished(self)
		target = null
		return
	target.clear()
	target = null
	return

func calculate_and_apply_forces(delta: float) -> void:
	if _spring == null:
		return
	var forces: Vector2 = calculate_forces()
	apply_forces(delta, forces)

func apply_forces(delta: float, forces: Vector2) -> void:
	if _spring == null:
		return
	set_velocity(
		PhysicsMethods.apply_central_force_to_velocity(
			get_velocity(),
			forces,
			get_mass(),
			delta
		)
	)

func calculate_local_spring_vector() -> Vector2:
	if target != null:
		return object.to_local(target.get_global_position())
	else:
		return Vector2.ZERO

func calculate_forces() -> Vector2:
	if _spring == null or object == null:
		return Vector2.ZERO
	var local_spring_vector: Vector2 = calculate_local_spring_vector()  # Should be connection2 - connection1
	var spring_force: Vector2 = _spring.calculate_spring_force(local_spring_vector)
	var damp_force: Vector2 = _spring.calculate_damp_force(get_velocity(), local_spring_vector)
	return spring_force + damp_force

func _init(
	object_: Node2D = null,
	target_: SpringObjectData = null
):
	object = object_
	target = target_
	_spring = null
