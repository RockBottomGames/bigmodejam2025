extends Node2D
class_name State

# ======================= overridable methods ==================================
# This section contains methods that are meant to be overridden
	
## _on_enter_state is a method that will be called once when the state is
## first entered.
func _on_enter_state(_prev_state: State) -> void:
	pass

## _state_process is a method that when overridden is called by the state
## state machine for processing.  The state machine will likely call it 
## from a parent's _physics_process or _process method
func _state_process(delta: float) -> void:
	pass
	
## _check_exit_state is a method that should be overridden and the return value
## is used to determine the next state to move to.  If not overridden
## the state will always remain in the state unless the containing state machine
## does a forced exit.
## -1 means to remain in the same state.
func _check_exit_state() -> int:
	return -1
	
## _on_exit_state is a method that will be called once when the state is
## first exited.
func _on_exit_state() -> void:
	pass
	
# ===================== END Overridable methods ================================

# ==================== _on_enter_state handling ================================
# this section of code is code that helps to efficiently run _on_enter_state
# method from "on_enter_state" public method

## on_enter_state will be called from a StateMachine Node when it switches
## state.
## DO NOT OVERRIDE
func on_enter_state(prev_state: State):
	_is_active = true
	_on_enter_state(prev_state)

# ================= END _on_enter_state handling ===============================

# ===================== _state_process handling ================================
# this section of code is code that helps to efficiently run _state_process
# method from "state_process" public method

## state_process will be called from a StateMachine Node's child_state_process
## public method.
## DO NOT OVERRIDE
func state_process(delta: float):
	_state_process_handler.state_process(delta)

## _is_active is used internally in the MyState base class to call processing
## only while active
var _is_active: bool = false:
	get:
		return _is_active
	set(value):
		if value == _is_active:
			return
		_is_active = value
		_set_state_process_handler()

## _active_state_process_handler will call _state_process if _state_process
## is defined.
var _active_state_process_handler: ActiveStateProcessHandler = null

## _inactive_state_process_handler will always simply call "pass" 
## this handler is only used when _is_active is false
## state should only be inactive when it has been exited but not yet swapped
## to a new state.
var _inactive_state_process_handler: StateProcessHandlerBase = null

## _state_process_handler holds current state process handler 
## (inactive or active)
var _state_process_handler: StateProcessHandlerBase = null

## _set_state_process_handler can be called to update _state_process_handler
## based on _is_active state
func _set_state_process_handler():
	if _is_active:
		_state_process_handler = _active_state_process_handler
	else:
		_state_process_handler = _inactive_state_process_handler

## _init_state_process_handlers called from _ready function to initialize
## state process handlers
func _init_state_process_handlers() -> void:
	_inactive_state_process_handler = StateProcessHandlerBase.new(self)
	_active_state_process_handler = ActiveStateProcessHandler.new(self)
	_set_state_process_handler()

# ================== END _state_process handling ===============================

# =================== _check_exit_state handling ===============================
# this section of code is code that helps to efficiently run _check_exit_state
# method from "check_exit_state" public method

## check_exit_state will be called from a StateMachine Node to check if the state
## should be exited.  The state machine will likely be called to run this 
## from in the _process or _physics_process methods
## DO NOT OVERRIDE
func check_exit_state() -> int:
	return _check_exit_state()

# ================= END _check_exit_state handling =============================

# ===================== _on_exit_state handling ================================
# this section of code is code that helps to efficiently run _on_exit_state
# method from "on_exit_state" public method

## on_exit_state will be called from a StateMachine Node once the state has
## exited.
## DO NOT OVERRIDE
func on_exit_state() -> void:
	_on_exit_state()

# =================== END _on_exit_state handling ==============================
var state_machine: StateMachine
func set_state_machine(new_state_machine: Variant) -> void:
	if new_state_machine is StateMachine:
		state_machine = get_parent() as StateMachine
	else:
		state_machine = null

func _enter_tree() -> void:
	set_state_machine(get_parent())

func _exit_tree() -> void:
	state_machine = null

func _ready() -> void:
	set_state_machine(get_parent())
	_init_state_process_handlers()
