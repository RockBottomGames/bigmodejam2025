extends StatePostprocessHandlerBase
class_name ActiveStatePostprocessHandler

# Things to do before processing state.
func state_postprocess(delta: float):
	_state._state_postprocess(delta)
