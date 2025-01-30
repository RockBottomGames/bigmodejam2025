extends SpringStateBase
class_name SpringUnhookedState

func _on_enter_state(_prev_state: State) -> void:
	print("Unhooked")
	spring_node_data.rotation_node.rotation = 0.0

func _state_postprocess(delta: float) -> void:
	spring_node_data.state_container_node.unhooked_state_postprocess.emit(delta)

func _check_exit_state() -> int:
	if spring_data.spring != null and spring_node_data.spring_object.target != null:
		return SpringStates.LERP_TO_HOOKED
	return SpringStates.NULL
