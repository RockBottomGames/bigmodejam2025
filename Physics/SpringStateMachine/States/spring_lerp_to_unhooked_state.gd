extends SpringStateBase
class_name SpringLerpToUnhookedState

var _lerp_time: float = 0.0
var _initial_rotation: float = 0.0

func _on_enter_state(_prev_state: State) -> void:
	print("LerpToUnhooked")
	_lerp_time = 0.0
	_initial_rotation = _get_closest_angle_to(spring_node_data.rotation_node.rotation, 0.0)

func _state_preprocess(delta: float) -> void:
	_lerp_time += delta * spring_data.lerp_speed

func _state_postprocess(delta: float) -> void:
	spring_node_data.rotation_node.rotation = lerpf(_initial_rotation, 0.0, _lerp_time)
	spring_node_data.state_container_node.lerp_to_unhooked_state_postprocess.emit(delta, _lerp_time)

func _check_exit_state() -> int:
	if spring_data.spring != null and spring_node_data.spring_object.target != null:
		return SpringStates.LERP_TO_HOOKED
	if _lerp_time > 1.0:
		return SpringStates.UNHOOKED
	return SpringStates.NULL
