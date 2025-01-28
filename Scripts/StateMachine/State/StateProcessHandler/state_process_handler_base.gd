class_name StateProcessHandlerBase

var _state: State = null

# Things to do before processing state.
func state_process(_delta: float):
	pass

func _init(state: State = null):
	_state = state
