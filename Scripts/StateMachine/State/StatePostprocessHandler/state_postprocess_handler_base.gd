class_name StatePostprocessHandlerBase

var _state: State = null

# Things to do before processing state.
func state_postprocess(_delta: float):
	pass

func _init(state: State = null):
	_state = state
