extends State
class_name VerticalStateBase

enum VerticalStates {
	NULL = -1,
	ON_FLOOR = 0,
	JUMPING = 1,
	FALLING = 2,
	TERMINAL_FALLING = 3
}

var player: Player = null

var vertical_node_data: VerticalExternalNodes = null:
	get:
		return state_machine.node_data as VerticalExternalNodes

var vertical_data: VerticalExternalData = null:
	get:
		return state_machine.data as VerticalExternalData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	player = vertical_node_data.player_node if vertical_node_data != null else null
