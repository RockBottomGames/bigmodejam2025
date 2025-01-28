extends HorizontalStateBase
class_name HorizontalSlowingState

@onready var right_state: HorizontalSlowingHelperBase = HorizontalSlowingRightHelper.new(player)
@onready var left_state: HorizontalSlowingHelperBase = HorizontalSlowingLeftHelper.new(player)

var current_state: HorizontalSlowingHelperBase = right_state

func _on_enter_state(_prev_state: State) -> void:
	if player.velocity.x >= 0:
		current_state = right_state
		current_state.player = player
	else:
		current_state = left_state
		current_state.player = player

func _state_process(delta: float) -> void:
	current_state.state_process(delta)

func _check_exit_state() -> int:
	return current_state.check_exit()

class HorizontalSlowingHelperBase:
	var player: Player = null
	
	func check_exit() -> int:
		return HorizontalStateBase.HorizontalStates.NULL
		
	func state_process(delta: float) -> void:
		pass
	
	func _init(player_: Player):
		player = player_

# state helper to manage slowing while character is moving right
class HorizontalSlowingRightHelper extends HorizontalSlowingHelperBase:
	# Input is currently <Nothing>
	# Wall collision is currently false
	# Velocity is currently <Right>
	# Velocity is currently > 0
	# Veclocity accelecration is currently <Left>
	var acc_direction: float = -1.0
	
	func check_exit() -> int:
		if InputGlobals.move_direction.x < 0:
			# Applied opposite direction
			return HorizontalStateBase.HorizontalStates.TURNING
		if InputGlobals.move_direction.x > 0:
			# Applied current direction
			return HorizontalStateBase.HorizontalStates.RUNNING
		if player.is_on_wall() or player.velocity.x <= 0:
			# Colliding right likely with no input
			# Even if slowing is actually true, change to still
			# and still will change to slow next physics update after
			return HorizontalStateBase.HorizontalStates.STILL
		return HorizontalStateBase.HorizontalStates.NULL
	
	func state_process(delta: float) -> void:
		player.velocity.x += player.current_run_speed.calculate_speed_delta_slow(delta, acc_direction)
		if player.velocity.x <= 0.0:
			# slowing reached the end, set to 0.0
			player.velocity.x = 0.0

# state helper to manage slowing while character is moving left
class HorizontalSlowingLeftHelper extends HorizontalSlowingHelperBase:
	# Input is currently <Nothing>
	# Wall collision is currently false
	# Velocity is currently <Left>
	# Velocity is currently <= 0
	# Veclocity accelecration is currently <Right>
	var acc_direction: float = 1.0
	
	func check_exit() -> int:
		if InputGlobals.move_direction.x > 0:
			# Applied opposite direction
			return HorizontalStateBase.HorizontalStates.TURNING
		if InputGlobals.move_direction.x < 0:
			# Applied current direction
			return HorizontalStateBase.HorizontalStates.RUNNING
		if player.is_on_wall() or player.velocity.x >= 0:
			# Colliding left likely with no input
			# Even if slowing is actually true, change to still
			# and still will change to slow next physics update after
			return HorizontalStateBase.HorizontalStates.STILL
		return HorizontalStateBase.HorizontalStates.NULL
	
	func state_process(delta: float) -> void:
		player.velocity.x += player.current_run_speed.calculate_speed_delta_slow(delta, acc_direction)
		if player.velocity.x >= 0.0:
			# slowing reached the end, set to 0.0
			player.velocity.x = 0.0
