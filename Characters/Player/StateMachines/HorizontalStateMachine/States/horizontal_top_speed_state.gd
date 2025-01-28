extends HorizontalStateBase
class_name HorizontalTopSpeedState

@onready var right_state: HorizontalTopSpeedHelperBase = HorizontalTopSpeedRightHelper.new(player)
@onready var left_state: HorizontalTopSpeedHelperBase = HorizontalTopSpeedLeftHelper.new(player)

var current_state: HorizontalTopSpeedHelperBase = right_state
var direction: int = 1

func _on_enter_state(_prev_state: State) -> void:
	if player.velocity.x >= 0:
		current_state = right_state
		current_state.player = player
		direction = 1
	else:
		current_state = left_state
		current_state.player = player
		direction = -1

func _check_exit_state() -> int:
	return current_state.check_exit()

class HorizontalTopSpeedHelperBase:
	var player: Player = null
	
	func check_exit() -> int:
		return HorizontalStateBase.HorizontalStates.NULL
	
	func _init(player_: Player):
		player = player_

# state helper to manage top speed going right
class HorizontalTopSpeedRightHelper extends HorizontalTopSpeedHelperBase:
	# Input is currently <Right>
	# Wall collision is currently false
	# Velocity is currently <Right>
	# Velocity is currently >= Top Speed
	func check_exit() -> int:
		if player.is_on_wall():
			# Colliding right likely
			return HorizontalStateBase.HorizontalStates.PUSHING
		if InputGlobals.move_direction.x <= 0:
			# Changed input directions
			# Even if turning is actually true, change to slowing
			# and slowing will change to turning next physics update after
			return HorizontalStateBase.HorizontalStates.SLOWING
		if player.velocity.x < player.current_run_speed.top_speed:
			# External force caused velocity to decrease below top_speed
			return HorizontalStateBase.HorizontalStates.RUNNING
		return HorizontalTopSpeedState.HorizontalStates.NULL

# state helper to manage top speed going left
class HorizontalTopSpeedLeftHelper extends HorizontalTopSpeedHelperBase:
	# Input is currently <Left>
	# Wall collision is currently false
	# Velocity is currently <Left>
	# Velocity is currently <= -Top Speed
	func check_exit() -> int:
		if player.is_on_wall():
			# Colliding left likely
			return HorizontalStateBase.HorizontalStates.PUSHING
		if InputGlobals.move_direction.x >= 0:
			# Changed input directions
			# Even if turning is actually true, change to slowing
			# and slowing will change to turning next physics update after
			return HorizontalStateBase.HorizontalStates.SLOWING
		if player.velocity.x > -player.current_run_speed.top_speed:
			# External force caused velocity to increase above -top_speed
			return HorizontalStateBase.HorizontalStates.RUNNING
		return HorizontalTopSpeedState.HorizontalStates.NULL
