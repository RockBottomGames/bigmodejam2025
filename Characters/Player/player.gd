extends CharacterBody2D
class_name Player

@onready var pointer: Node2D = %Pointer
@onready var force_spring: Line2D = $ForceSpring
@onready var force_damp: Line2D = $ForceDamp
@onready var equilibrium: Line2D = $Equilibrium
@onready var ray_cast_fan: RayCastFan2D = %RayCastFan
@onready var terminal_velocity: float = 5000
@onready var vertical_state_machine: StateMachine = %VerticalStateMachine
@onready var horizontal_state_machine: StateMachine = %HorizontalStateMachine
@onready var rope: Line2D = %Rope
@onready var rope_guide: Line2D = %RopeGuide
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animation_tree: AnimationTree = %AnimationTree
@onready var player_sprite_container: Node2D = %PlayerSpriteContainer
@onready var player_sprite: Node2D = %PlayerSprite
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var player_body: Node2D = %PlayerBody
@onready var player_body_internal: Node2D = %PlayerBodyInternal
@onready var spring_object: SpringDataCharacterBody2D = %SpringObject
@onready var spring_state_machine_container: SpringStateMachineContainer = %SpringStateMachineContainer

@export var ground_run_speed: RunSpeed = RunSpeed.new(
	3000, # Max Run Speed
	3000, # Acceleration
	0.5, # Slow Percentage
	2.0, # Turn Percentage
)

@export var air_run_speed: RunSpeed = RunSpeed.new(
	3000, # Max Run Speed
	1500, # Acceleration
	0.0, # Slow Percentage
	1.0, # Turn Percentage
)

var _prev_rotation: float = 0.0
var _prev_body_distance: float = 0.0
var current_run_speed: RunSpeed = ground_run_speed

@export var boost_speed: float = 3000

var _last_input_was_mouse: bool = true
var _is_rehook: bool = false

var is_hooked: bool = false
var intended_direction: Vector2 = Vector2.ZERO
var previous_direction: Vector2 = Vector2(0, -1)
var _collider: Node2D = null
var _colliding_ray_cast: RayCast2D = null
var _hooked_collider: Node2D = null
var _local_collider_pos: Vector2 = Vector2.ZERO
@export var hookshot_slide_speed: float = 2000

@export var spring_data: SpringData = null:
	get:
		return spring_state_machine_container.spring
	set(value):
		spring_state_machine_container.spring = value

@export var mass: float = 1.0:
	get:
		return spring_object.get_mass()
	set(value):
		spring_object.set_mass(value)

@export var spring_constant: float = 45.0:
	get:
		return spring_data.spring_constant
	set(value):
		spring_data.spring_constant = value

@export var spring_damp_coef: float = 15.0:
	get:
		return spring_data.damping_coefficient
	set(value):
		spring_data.damping_coefficient = value

var _equilibrium_distance: float = 0.0:
	get:
		return spring_data.equilibrium_distance
	set(value):
		spring_data.equilibrium_distance = value

@export var spring_shorten_percentage: float = 0.8

func get_prevs():
	_prev_rotation = player_body.rotation
	_prev_body_distance = player_body_internal.position.y

func disconnect_spring():
	spring_object.relinquish_target()
	get_prevs()
	_clear_spring_data()

func _clear_spring_data():
	if is_hooked:
		is_hooked = false
		_is_rehook = false
		_hooked_collider = null
		var capsule: CapsuleShape2D = collision_shape_2d.shape
		capsule.height = 415
		collision_shape_2d.position.y = 104
		animation_tree.set("parameters/blend_position", -1)
		_prev_rotation = player_body.rotation
	

func attempt_connect_spring(hook_to: Node2D) -> bool:
	get_prevs()
	if !spring_object.attempt_acquire_target(hook_to, spring_data):
		_clear_spring_data()
		return false
	if !is_hooked:
		is_hooked = true
		_is_rehook = false
		var capsule: CapsuleShape2D = collision_shape_2d.shape
		capsule.height = 190
		collision_shape_2d.position.y = 0
		animation_tree.set("parameters/blend_position", 1)
	else:
		_is_rehook = true
	_hooked_collider = hook_to
	_equilibrium_distance = spring_object.calculate_local_spring_vector().length() * spring_shorten_percentage
	return true

func get_input(delta: float):
	var local_mouse: Vector2 = get_local_mouse_position()
	InputGlobals.physics_process_update_input_globals(local_mouse)

	if InputGlobals.is_boost_just_pressed():
		velocity = PhysicsMethods.apply_central_impulse_to_velocity(velocity, InputGlobals.look_direction * boost_speed)
	
	if InputGlobals.is_hook_pressed() and _collider != null and _collider != _hooked_collider:
		attempt_connect_spring(_collider)
			
	if is_hooked and InputGlobals.is_hook_release_just_pressed():
		disconnect_spring()
		
	if InputGlobals.is_hook_loosen_pressed():
		_equilibrium_distance += hookshot_slide_speed * delta
			
	if InputGlobals.is_hook_tighten_pressed():
		_equilibrium_distance -= hookshot_slide_speed * delta

func _update_colliding_ray_cast() -> void:
	_colliding_ray_cast = ray_cast_fan.get_colliding_raycast()

func _update_collider() -> void:
	if _colliding_ray_cast == null:
		_collider = null
		return
	_collider = _colliding_ray_cast.get_collider()

var is_in_air = false

func update_run_speeds():
	var next_is_in_air = (vertical_state_machine.data as VerticalExternalData).is_in_air
	if is_in_air != next_is_in_air:
		is_in_air = next_is_in_air
		current_run_speed = air_run_speed if next_is_in_air else ground_run_speed

func _display_guide_rope() -> void:
	if _collider != null and _collider != _hooked_collider:
		rope_guide.show()
		rope_guide.points[1] = to_local(_collider.global_position)
	else:
		rope_guide.points[1] = Vector2.ZERO
		rope_guide.hide()

func _display_rope() -> void:
	if player_body_internal.position.y > 0:
		rope.show()
		var angle_vect: Vector2 = to_local(player_body_internal.global_position)
		var updated_vect: Vector2 = Vector2(angle_vect.length() + 244, 0).rotated(angle_vect.angle())
		rope.points[1] = updated_vect
	else:
		rope.hide()
		rope.points[1] = Vector2.ZERO

func _display_ropes() -> void:
	_display_guide_rope()
	_display_rope()

func _check_and_set_hooked_flipped():
	var added_vectors = -_local_collider_pos + velocity
	var rotated_vectors = added_vectors.rotated(-(-_local_collider_pos).angle())
	if rotated_vectors.y > 0 and _flipped:
		_flipped = false
		player_sprite.apply_scale(Vector2(-1, 1))
		player_body_internal.apply_scale(Vector2(-1, 1))
	elif rotated_vectors.y < 0 and !_flipped:
		_flipped = true
		player_sprite.apply_scale(Vector2(-1, 1))
		player_body_internal.apply_scale(Vector2(-1, 1))

func _check_and_set_unhooked_flipped():
	if velocity.x > 0 and _flipped:
		_flipped = false
		player_sprite.apply_scale(Vector2(-1, 1))
		player_body_internal.apply_scale(Vector2(-1, 1))
	elif velocity.x < 0 and !_flipped:
		_flipped = true
		player_sprite.apply_scale(Vector2(-1, 1))
		player_body_internal.apply_scale(Vector2(-1, 1))

var _initial_body_angle_diff: float = 0.0

func _on_enter_spring_unhooked_state() -> void:
	player_body.rotation = 0.0 
	player_body_internal.position.y = 0.0
	
func _postprocess_spring_unhooked_state(delta: float) -> void:
	_check_and_set_unhooked_flipped()

func _postprocess_spring_lerp_to_hooked_state(delta: float, lerp_time: float) -> void:
	player_body.rotation = _local_collider_pos.angle() + (-PI * 0.5)
	player_body_internal.position.y = lerpf(_prev_body_distance, _local_collider_pos.length() - 288, lerp_time)
	_check_and_set_hooked_flipped()

func _postprocess_spring_hooked_state(delta: float) -> void:
	player_body.rotation = _local_collider_pos.angle() + (-PI * 0.5)
	player_body_internal.position.y = _local_collider_pos.length() - 288
	_check_and_set_hooked_flipped()
	
func _on_enter_spring_lerp_to_rehooked_state() -> void:
	_prev_rotation = player_body.rotation
	var target_angle: float = PhysicsMethods.get_closest_angle_to(_local_collider_pos.angle() + (-PI * 0.5), _prev_rotation)
	_initial_body_angle_diff = _prev_rotation - target_angle

func _postprocess_spring_lerp_to_rehooked_state(delta: float, lerp_time: float) -> void:
	var lerped_difference: float = lerpf(_initial_body_angle_diff, 0.0, lerp_time)
	var target_angle: float = _local_collider_pos.angle() + (-PI * 0.5)
	player_body.rotation = target_angle + lerped_difference
	player_body_internal.position.y = lerpf(_prev_body_distance, _local_collider_pos.length() - 288, lerp_time)
	_check_and_set_hooked_flipped()
	
func _on_enter_spring_lerp_to_unhooked_state() -> void:
	_prev_rotation = PhysicsMethods.get_closest_angle_to(player_body.rotation, 0.0)
	_prev_body_distance = player_body_internal.position.y

func _postprocess_spring_lerp_to_unhooked_state(delta: float, lerp_time: float) -> void:
	player_body.rotation = lerpf(_prev_rotation, 0.0, lerp_time)
	player_body_internal.position.y = lerpf(_prev_body_distance, 0.0, lerp_time)
	_check_and_set_unhooked_flipped()

func _physics_process(delta):
	_update_colliding_ray_cast()
	_update_collider()
	get_input(delta)
	pointer.rotation = InputGlobals.look_angle
	_local_collider_pos = spring_object.calculate_local_spring_vector()
	spring_state_machine_container.spring_state_machine.child_state_preprocess(delta)
	spring_state_machine_container.spring_state_machine.check_and_exit_child_state()
	vertical_state_machine.child_state_process(delta)
	vertical_state_machine.check_and_exit_child_state()
	horizontal_state_machine.check_and_exit_child_state()
	horizontal_state_machine.child_state_process(delta)
	spring_state_machine_container.spring_state_machine.child_state_process(delta)
		
	#velocity.x = lerp(velocity.x, InputGlobals.move_direction.x * run_speed, 0.05)
	# apply_damping(delta)
	move_and_slide()
	_local_collider_pos = spring_object.calculate_local_spring_vector()
	spring_state_machine_container.spring_state_machine.child_state_postprocess(delta)
	_display_ropes()

var _flipped: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_in_air = false
	current_run_speed = ground_run_speed
	spring_state_machine_container.spring_state_machine.reset()
	vertical_state_machine.reset()
	horizontal_state_machine.reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
