extends VerticalStateBase
class_name VerticalTerminalFallingState

func _on_enter_state(_prev_state: State) -> void:
	vertical_data.is_in_air = true
	player.update_run_speeds()
	
func _check_exit_state() -> int:
	if !player.is_on_floor():
		if player.velocity.y > 0:
			if player.velocity.y > player.terminal_velocity:
				return VerticalStates.NULL
			return VerticalStates.FALLING
		return VerticalStates.JUMPING
	return VerticalStates.ON_FLOOR
