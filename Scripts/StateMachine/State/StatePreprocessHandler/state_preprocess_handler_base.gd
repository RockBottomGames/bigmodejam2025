class_name StatePreprocessHandlerBase

var _state: State = null

# Things to do before processing state.
func state_preprocess(_delta: float):
	pass

func _init(state: State = null):
	_state = state
