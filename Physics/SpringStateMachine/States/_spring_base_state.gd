extends State
class_name SpringStateBase

enum SpringStates {
	NULL = -1,
	UNHOOKED = 0,
	LERP_TO_HOOKED = 1,
	HOOKED = 2,
	LERP_TO_REHOOKED = 3,
	LERP_TO_UNHOOKED = 4
}

func _get_closest_angle_to(initial_angle_to: float, angle_from: float) -> float:
	return PhysicsMethods.get_closest_angle_to(initial_angle_to, angle_from)

var spring_node_data: SpringExternalNodes = null:
	get:
		return state_machine.node_data as SpringExternalNodes

var spring_data: SpringExternalData = null:
	get:
		return state_machine.data as SpringExternalData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
