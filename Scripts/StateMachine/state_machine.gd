extends State
class_name StateMachine

@export var states: Array[State] = []
@export var data: ExternalStateData = null
@export var node_data: ExternalStateNodes = null

var _current_state: State = null
var _default_state: int = 0

## switch_states switches state based on state_index from states array
## or child states of this state machine.  Can be called directly to force
## a state change from outside of the states.
func switch_child_states(state_index: int) -> void:
	## if state_index is out of bounds, do nothing.
	if state_index < 0 or state_index >= states.size():
		return
	var prev_state = _current_state
	if prev_state != null:
		prev_state.on_exit_state()
	_current_state = states[state_index]
	_current_state.on_enter_state(prev_state)

## reset switches child state back to default
## and calls reset on data
func reset() -> void:
	if data != null:
		data.reset()
	if node_data != null:
		node_data.reset()
	switch_child_states(_default_state)

## optionally call child_state_preprocess periodically, likely from _process or 
## _physics_process before child_state_process
func child_state_preprocess(delta: float) -> void:
	state_preprocess(delta)
	_current_state.state_preprocess(delta)

## call child_state_process periodically, likely from _process or 
## _physics_process
func child_state_process(delta: float) -> void:
	state_process(delta)
	_current_state.state_process(delta)

## optionally call child_state_postprocess periodically, likely from _process or 
## _physics_process after child_state_process
func child_state_postprocess(delta: float) -> void:
	state_postprocess(delta)
	_current_state.state_postprocess(delta)

## internally called to check if the child state should be switched.
func _check_exit_child_state() -> int:
	return _current_state.check_exit_state()

## checks if should exit child state, and if it should exit child state
## calls switch_child_state with the new state index
func check_and_exit_child_state() -> void:
	var next_child_state: int = _check_exit_child_state()
	if next_child_state >= 0:
		switch_child_states(next_child_state)

func _ready() -> void:
	super()
	# You should only either make states via scripts or make states via editor.
	# Creating states via editor is recommended.
	
	# states being empty means that states is likely made via editor.
	if states.is_empty():
		for state in get_children():
			if state is State:
				states.append(state)
	# states being filled means that states is likely made via script.
	elif get_children().is_empty():
		for state in states:
			add_child(state)
