extends HorizontalStateBase
class_name HorizontalPushingState

@onready var right_state: HorizontalPushingHelperBase = HorizontalPushingRightHelper.new(player)
@onready var left_state: HorizontalPushingHelperBase = HorizontalPushingLeftHelper.new(player)

var current_state: HorizontalPushingHelperBase = right_state
var direction: int = 1

func _on_enter_state(_prev_state: State) -> void:
	if InputGlobals.move_direction.x >= 0:
		current_state = right_state
		current_state.player = player
		direction = 1
	else:
		current_state = left_state
		current_state.player = player
		direction = -1

func _state_process(delta: float) -> void:
	player.velocity.x += player.current_run_speed.calculate_speed_delta_run(delta, direction as float)

func _check_exit_state() -> int:
	return current_state.check_exit()

class HorizontalPushingHelperBase:
	var player: Player = null
	
	func check_exit() -> int:
		return HorizontalStateBase.HorizontalStates.NULL
	
	func _init(player_: Player):
		player = player_

# state helper to manage pushing right
class HorizontalPushingRightHelper extends HorizontalPushingHelperBase:
	# Input is currently <Right>
	# Wall collision is currently true
	# Velocity can be anything
	func check_exit() -> int:
		if InputGlobals.move_direction.x <= 0:
			# Changed directions
			# Even if running is actually true, change to still
			# and still will change to running next physics update after
			return HorizontalStateBase.HorizontalStates.STILL
		if !player.is_on_wall():
			# No longer colliding right
			return HorizontalStateBase.HorizontalStates.RUNNING
		return HorizontalStateBase.HorizontalStates.NULL

# state helper to manage pushing left
class HorizontalPushingLeftHelper extends HorizontalPushingHelperBase:
	# Input is currently <Left>
	# Wall collision is currently true
	# Velocity can be anything
	func check_exit() -> int:
		if InputGlobals.move_direction.x >= 0:
			# Changed directions
			# Even if running is actually true, change to still
			# and still will change to running next physics update after
			return HorizontalStateBase.HorizontalStates.STILL
		if !player.is_on_wall():
			# No longer colliding left
			return HorizontalStateBase.HorizontalStates.RUNNING
		return HorizontalStateBase.HorizontalStates.NULL
