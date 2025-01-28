extends State
class_name HorizontalStateBase

enum HorizontalStates {
	NULL = -1,
	STILL = 0,
	RUNNING = 1,
	TOP_SPEED = 2,
	SLOWING = 3,
	TURNING = 4,
	PUSHING = 5
}

var player: Player = null

var horizontal_node_data: HorizontalExternalNodes = null:
	get:
		return state_machine.node_data as HorizontalExternalNodes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	player = horizontal_node_data.player_node if horizontal_node_data != null else null
