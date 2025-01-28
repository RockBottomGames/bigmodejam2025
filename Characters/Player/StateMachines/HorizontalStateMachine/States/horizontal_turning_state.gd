extends HorizontalStateBase
class_name HorizontalTurningState

@onready var right_state: HorizontalTurningHelperBase = HorizontalTurningRightHelper.new(player)
@onready var left_state: HorizontalTurningHelperBase = HorizontalTurningLeftHelper.new(player)

var current_state: HorizontalTurningHelperBase = right_state
var direction: int = 1

func _on_enter_state(_prev_state: State) -> void:
	if player.velocity.x >= 0:
		current_state = right_state
		current_state.player = player
		# acc direction is opposite to move direction
		direction = -1
	else:
		current_state = left_state
		current_state.player = player
		# acc direction is opposite to move direction
		direction = 1

func _state_process(delta: float) -> void:
	player.velocity.x += player.current_run_speed.calculate_speed_delta_turn(delta, direction)

func _check_exit_state() -> int:
	return current_state.check_exit()

class HorizontalTurningHelperBase:
	var player: Player = null
	
	func check_exit() -> int:
		return HorizontalStateBase.HorizontalStates.NULL
	
	func _init(player_: Player):
		player = player_

# state helper to manage turning left (denoted as right because moving right)
class HorizontalTurningRightHelper extends HorizontalTurningHelperBase:
	# Input is currently <Left>
	# Wall collision is currently false
	# Velocity is currently <Right>
	# Velocity is currently > 0
	
	func check_exit() -> int:
		if player.is_on_wall():
			# Colliding right likely with no input
			return HorizontalStateBase.HorizontalStates.PUSHING
		if InputGlobals.move_direction.x == 0:
			# Applied no direction
			if player.velocity.x == 0:
				return HorizontalStateBase.HorizontalStates.STILL
			return HorizontalStateBase.HorizontalStates.SLOWING
		if InputGlobals.move_direction.x > 0 or player.velocity.x <= 0:
			# Applied velocity direction or finished turning
			return HorizontalStateBase.HorizontalStates.RUNNING
		return HorizontalStateBase.HorizontalStates.NULL

# state helper to manage turning right (denoted as left because moving left)
class HorizontalTurningLeftHelper extends HorizontalTurningHelperBase:
	# Input is currently <Right>
	# Wall collision is currently false
	# Velocity is currently <Left>
	# Velocity is currently <= 0
	
	func check_exit() -> int:
		if player.is_on_wall():
			# Colliding right likely with no input
			return HorizontalStateBase.HorizontalStates.PUSHING
		if InputGlobals.move_direction.x == 0:
			# Applied no direction
			if player.velocity.x == 0:
				return HorizontalStateBase.HorizontalStates.STILL
			return HorizontalStateBase.HorizontalStates.SLOWING
		if InputGlobals.move_direction.x < 0 or player.velocity.x >= 0:
			# Applied velocity direction or finished turning
			return HorizontalStateBase.HorizontalStates.RUNNING
		return HorizontalStateBase.HorizontalStates.NULL
