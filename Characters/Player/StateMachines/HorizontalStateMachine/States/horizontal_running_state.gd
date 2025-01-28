extends HorizontalStateBase
class_name HorizontalRunningState

@onready var right_state: HorizontalRunningHelperBase = HorizontalRunningRightHelper.new(player)
@onready var left_state: HorizontalRunningHelperBase = HorizontalRunningLeftHelper.new(player)

var current_state: HorizontalRunningHelperBase = right_state
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

func _check_exit_state() -> int:
	return current_state.check_exit()

func _state_process(delta: float) -> void:
	player.velocity.x += player.current_run_speed.calculate_speed_delta_run(delta, direction as float)

class HorizontalRunningHelperBase:
	var player: Player = null
	
	func check_exit() -> int:
		return HorizontalStateBase.HorizontalStates.NULL
	
	func _init(player_: Player):
		player = player_

# state helper to manage running right
class HorizontalRunningRightHelper extends HorizontalRunningHelperBase:
	# Input is currently <Right>
	# Wall collision is currently false
	# Velocity is currently <Right>
	# Velocity is currently < Top Speed
	func check_exit() -> int:
		if player.is_on_wall():
			# Colliding right likely
			return HorizontalStateBase.HorizontalStates.PUSHING
		if InputGlobals.move_direction.x <= 0 or player.velocity.x <= 0:
			# Changed physics or input directions
			# Even if turning is actually true, change to slowing
			# and slowing will change to turning next physics update after
			return HorizontalStateBase.HorizontalStates.SLOWING
		if player.velocity.x >= player.current_run_speed.top_speed:
			# No longer colliding right
			return HorizontalStateBase.HorizontalStates.TOP_SPEED
		return HorizontalStateBase.HorizontalStates.NULL

# state helper to manage running left
class HorizontalRunningLeftHelper extends HorizontalRunningHelperBase:
	# Input is currently <Left>
	# Wall collision is currently false
	# Velocity is currently <Left>
	# Velocity is currently > -Top Speed
	func check_exit() -> int:
		if player.is_on_wall():
			# Colliding left likely
			return HorizontalStateBase.HorizontalStates.PUSHING
		if InputGlobals.move_direction.x >= 0 or player.velocity.x >= 0:
			# Changed physics or input directions
			# Even if turning is actually true, change to slowing
			# and slowing will change to turning next physics update after
			return HorizontalStateBase.HorizontalStates.SLOWING
		if player.velocity.x <= -player.current_run_speed.top_speed:
			# No longer colliding right
			return HorizontalStateBase.HorizontalStates.TOP_SPEED
		return HorizontalStateBase.HorizontalStates.NULL
