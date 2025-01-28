extends StateProcessHandlerBase
class_name ActiveStateProcessHandler

# Things to do before processing state.
func state_process(delta: float):
	_state._state_process(delta)
