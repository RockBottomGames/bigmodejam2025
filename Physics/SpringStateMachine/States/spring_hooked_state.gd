extends SpringStateBase
class_name SpringHookedState

var _prev_target: SpringObjectData = null

func _on_enter_state(_prev_state: State) -> void:
	_prev_target = spring_node_data.spring_object.target
	spring_node_data.state_container_node.on_enter_hooked_state.emit()

func _state_process(delta: float) -> void:
	spring_node_data.spring_object.calculate_and_apply_forces(delta)

func _state_postprocess(delta: float) -> void:
	var _local_vector: Vector2 = spring_node_data.spring_object.calculate_local_spring_vector()
	spring_node_data.rotation_node.rotation = _local_vector.angle() + spring_data.hooked_rotation
	spring_node_data.state_container_node.postprocess_hooked_state.emit(delta)

func _on_exit_state():
	spring_node_data.state_container_node.on_exit_hooked_state.emit()

func _check_exit_state() -> int:
	if spring_data.spring == null or spring_node_data.spring_object.target == null:
		return SpringStates.LERP_TO_UNHOOKED
	if spring_node_data.spring_object.target != _prev_target:
		return SpringStates.LERP_TO_REHOOKED
	return SpringStates.NULL
