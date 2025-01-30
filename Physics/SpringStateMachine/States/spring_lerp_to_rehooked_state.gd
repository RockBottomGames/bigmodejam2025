extends SpringStateBase
class_name SpringLerpToRehookedState

var _prev_target: SpringObjectData = null
var _lerp_time: float = 0.0
var _initial_difference: float = 0.0

func _on_enter_state(_prev_state: State) -> void:
	_prev_target = spring_node_data.spring_object.target
	_lerp_time = 0.0
	var local_vector: Vector2 = spring_node_data.spring_object.calculate_local_spring_vector()
	var target_angle = _get_closest_angle_to(local_vector.angle() + spring_data.hooked_rotation, spring_node_data.rotation_node.rotation)
	_initial_difference = spring_node_data.rotation_node.rotation - target_angle 
	spring_node_data.state_container_node.on_enter_lerp_to_rehooked_state.emit()

func _state_preprocess(delta: float) -> void:
	_lerp_time += delta * spring_data.lerp_speed

func _state_process(delta: float) -> void:
	spring_node_data.spring_object.calculate_and_apply_forces(delta)

func _state_postprocess(delta: float) -> void:
	var lerped_difference: float = lerpf(_initial_difference, 0.0, _lerp_time)
	var local_vector: Vector2 = spring_node_data.spring_object.calculate_local_spring_vector()
	var target_angle: float = local_vector.angle() + spring_data.hooked_rotation
	spring_node_data.rotation_node.rotation = target_angle + lerped_difference
	spring_node_data.state_container_node.postprocess_lerp_to_rehooked_state.emit(delta, _lerp_time)

func _on_exit_state():
	spring_node_data.state_container_node.on_exit_lerp_to_rehooked_state.emit()

func _check_exit_state() -> int:
	if spring_data.spring == null or spring_node_data.spring_object.target == null:
		return SpringStates.LERP_TO_UNHOOKED
	if spring_node_data.spring_object.target != _prev_target:
		return SpringStates.LERP_TO_REHOOKED
	if _lerp_time > 1.0:
		return SpringStates.HOOKED
	return SpringStates.NULL
