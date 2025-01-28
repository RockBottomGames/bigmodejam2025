extends HorizontalStateBase
class_name HorizontalStillState
	
func _check_exit_state() -> int:
	if InputGlobals.move_direction.x != 0:
		# Applied any direction
		return HorizontalStates.RUNNING
	if player.velocity.x != 0:
		# External force caused movement
		return HorizontalStates.SLOWING
	return HorizontalStates.NULL
