extends StatePreprocessHandlerBase
class_name ActiveStatePreprocessHandler

# Things to do before processing state.
func state_preprocess(delta: float):
	_state._state_preprocess(delta)
