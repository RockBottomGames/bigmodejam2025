extends Node

var using_mouse: bool = true

# ================================ Input Checks ====================================================

func is_boost_just_pressed() -> bool:
	if Input.is_action_just_pressed("boost"):
		return true
	return false

func is_hook_pressed() -> bool:
	if !Input.is_action_pressed("controller_modifier"):
		if Input.is_action_pressed("hook"):
			return true
	return false
	
func is_hook_release_just_pressed() -> bool:
	if Input.is_action_just_pressed("hook_release"):
		return true
	if Input.is_action_pressed("controller_modifier"):
		if Input.is_action_just_pressed("controller_modifier_hook_release"):
			return true
	return false

func is_hook_tighten_pressed() -> bool:
	if Input.is_action_pressed("hook_tighten"):
		return true
	if Input.is_action_pressed("controller_modifier"):
		if Input.is_action_pressed("controller_modifier_hook_tighten"):
			return true
	return false

func is_hook_loosen_pressed() -> bool:
	if Input.is_action_pressed("hook_loosen"):
		return true
	if Input.is_action_pressed("controller_modifier"):
		if Input.is_action_pressed("controller_modifier_hook_loosen"):
			return true
	return false
	

# ============================== End Input Checks ==================================================

# ================================= Look Inputs ====================================================

var _look_direction: Vector2 = Vector2(0, 1)
var look_direction: Vector2 = Vector2(0, 1):
	get:
		return _look_direction
var _look_angle_needs_update = true
var _look_angle: float = 0.0
var look_angle: float = 0.0:
	get:
		if _look_angle_needs_update:
			_look_angle = _look_direction.angle()
			_look_angle_needs_update = false
		return _look_angle

func _get_axis_look_direction() -> Vector2:
	return Input.get_vector("look_left", "look_right", "look_up", "look_down").normalized()

func physics_process_update_look_direction_globals(mouse_position: Vector2) -> void:
	var input_look_direction = _get_axis_look_direction()
	
	if input_look_direction != Vector2.ZERO:
		using_mouse = false
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		using_mouse = true
	
	var next_direction = mouse_position.normalized() if using_mouse else _get_axis_look_direction()
	
	# if the mouse is not 0,0 and _look_direction is different than mouse
	if next_direction != Vector2.ZERO and _look_direction != next_direction:
		# update look direction
		_look_direction = next_direction
		# mark angle as update needed
		_look_angle_needs_update = true

# =============================== End Look Inputs ==================================================

# ================================= Move Inputs ====================================================

var _move_direction: Vector2 = Vector2.ZERO
var move_direction: Vector2 = Vector2.ZERO:
	get:
		return _move_direction
		
func physics_process_update_move_direction_globals() -> void:
	var next_direction: Vector2 = Vector2(Input.get_axis("move_left", "move_right"), 0).normalized()

	# if the mouse is not 0,0 and _move_direction is different than mouse
	if _move_direction != next_direction:
		# update move direction
		_move_direction = next_direction

# =============================== End Move Inputs ==================================================

func physics_process_update_input_globals(mouse_position: Vector2) -> void:
	physics_process_update_look_direction_globals(mouse_position)
	physics_process_update_move_direction_globals()
