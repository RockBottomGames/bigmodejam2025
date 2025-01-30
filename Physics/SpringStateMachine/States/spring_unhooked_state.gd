extends SpringStateBase
class_name SpringUnhookedState

func _on_enter_state(_prev_state: State) -> void:
	spring_node_data.rotation_node.rotation = 0.0
	spring_node_data.state_container_node.on_enter_unhooked_state.emit()

func _state_postprocess(delta: float) -> void:
	spring_node_data.state_container_node.postprocess_unhooked_state.emit(delta)

func _on_exit_state():
	spring_node_data.state_container_node.on_exit_unhooked_state.emit()

func _check_exit_state() -> int:
	if spring_data.spring != null and spring_node_data.spring_object.target != null:
		return SpringStates.LERP_TO_HOOKED
	return SpringStates.NULL
