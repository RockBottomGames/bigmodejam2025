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

var _lerp_amount:float = 1.0
var _prev_rotation: float = 0.0
var _prev_body_distance: float = 0.0
var current_run_speed: RunSpeed = ground_run_speed

@export var boost_speed = 3000

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
var _equilibrium_distance: float = 0.0
@export var spring_constant: float = 45
@export var damping_coefficient: float = 15
@export var grapple_shortening: float = 0.8
@export var mass: float = 1.0
@export var self_spring_connection_data: SpringData.SpringObjectData = SpringData.SpringObjectData.new()
@export var hook_spring_connection_data: SpringData.SpringObjectData = SpringData.SpringObjectData.new()
@export var spring_data: SpringData = SpringData.new(self_spring_connection_data, hook_spring_connection_data)

func apply_central_impulse(impulse: Vector2):
	velocity += impulse
	
func apply_central_force(force: Vector2, delta: float):
	velocity += (force / mass) * delta

func apply_damping(delta: float):
	velocity = velocity * (1 - (ProjectSettings.get_setting_with_override("physics/2d/default_linear_damp") * delta))

func _reset_self_spring_connection_data():
	spring_data.damping_coefficient = damping_coefficient
	spring_data.spring_constant = spring_constant
	spring_data.equilibrium_distance = _equilibrium_distance
	spring_data.local_spring_vector = Vector2.ZERO
	self_spring_connection_data.mass = mass
	self_spring_connection_data.position = global_position
	self_spring_connection_data.applied_force = Vector2.ZERO
	self_spring_connection_data.velocity = velocity

func _update_self_spring_connection_data():
	spring_data.damping_coefficient = damping_coefficient
	spring_data.spring_constant = spring_constant
	spring_data.equilibrium_distance = _equilibrium_distance
	spring_data.local_spring_vector = Vector2.ZERO
	self_spring_connection_data.position = global_position
	self_spring_connection_data.velocity = velocity

func _reset_hook_spring_connection_data():
	if _collider == null:
		hook_spring_connection_data.mass = 1.0
		self_spring_connection_data.velocity = Vector2.ZERO
		hook_spring_connection_data.position = Vector2.ZERO
		self_spring_connection_data.applied_force = Vector2.ZERO
		return
	hook_spring_connection_data.position = _collider.global_position
	self_spring_connection_data.applied_force = Vector2.ZERO
	if _collider is RigidBody2D:
		var _rigid_body_collider: RigidBody2D = _collider as RigidBody2D
		hook_spring_connection_data.mass = _rigid_body_collider.mass
		self_spring_connection_data.velocity = _rigid_body_collider.linear_velocity
	elif _collider is StaticBody2D:
		var _static_body_collider: StaticBody2D = _collider as StaticBody2D
		hook_spring_connection_data.mass = 1.0
		self_spring_connection_data.velocity = Vector2.ZERO
	elif _collider is CharacterBody2D:
		var _char_body_collider: CharacterBody2D = _collider as CharacterBody2D
		hook_spring_connection_data.mass = _char_body_collider.mass if "mass" in _char_body_collider else 1.0
		self_spring_connection_data.velocity = _char_body_collider.velocity

func _update_and_recalculate_all_spring_connection_data(delta: float):
	_update_self_spring_connection_data()
	if _collider == null:
		self_spring_connection_data.velocity = Vector2.ZERO
		hook_spring_connection_data.position = Vector2.ZERO
		return
	self_spring_connection_data.position = global_position
	if _collider is RigidBody2D:
		var _rigid_body_collider: RigidBody2D = _collider as RigidBody2D
		self_spring_connection_data.velocity = _rigid_body_collider.linear_velocity
		spring_data.calculate_and_update_connection_velocities(delta)
		_rigid_body_collider.apply_central_force(hook_spring_connection_data.applied_force)
	elif _collider is CharacterBody2D:
		var _char_body_collider: CharacterBody2D = _collider as CharacterBody2D
		self_spring_connection_data.velocity = _char_body_collider.velocity
		spring_data.calculate_and_update_connection_velocities(delta)
	else:
		self_spring_connection_data.velocity = Vector2.ZERO
		spring_data.calculate_and_update_connection_velocities(delta)
	velocity = self_spring_connection_data.velocity

func _reset_spring_connection_data():
	_reset_self_spring_connection_data()
	_reset_hook_spring_connection_data()

func get_input(delta: float):
	var local_mouse: Vector2 = get_local_mouse_position()
	InputGlobals.physics_process_update_input_globals(local_mouse)

	if InputGlobals.is_boost_just_pressed():
		apply_central_impulse(InputGlobals.look_direction * boost_speed)
	
	if !is_hooked and _collider != null and InputGlobals.is_hook_pressed():
		is_hooked = true
		_is_rehook = false
		_prev_rotation = player_sprite_container.rotation
		_prev_body_distance = player_body_internal.position.y
		_lerp_amount = 0.0
		var capsule: CapsuleShape2D = collision_shape_2d.shape
		capsule.height = 190
		collision_shape_2d.position.y = 0
		animation_tree.set("parameters/blend_position", 1)
		_hooked_collider = _collider
		_update_local_hooked_collider_pos()
		_reset_self_spring_connection_data()
		_reset_hook_spring_connection_data()
		_equilibrium_distance = _local_collider_pos.length() * grapple_shortening
	elif _collider != null and _collider != _hooked_collider and InputGlobals.is_hook_pressed():
		_hooked_collider = _collider
		_is_rehook = true
		_lerp_amount = 0.0
		_prev_rotation = player_sprite_container.rotation
		_prev_body_distance = player_body_internal.position.y
		_update_local_hooked_collider_pos()
		_equilibrium_distance = _local_collider_pos.length() * grapple_shortening
	if is_hooked and InputGlobals.is_hook_release_just_pressed():
		is_hooked = false
		_prev_rotation = player_sprite_container.rotation
		_prev_body_distance = player_body_internal.position.y
		_lerp_amount = 0.0
		var capsule: CapsuleShape2D = collision_shape_2d.shape
		capsule.height = 415
		collision_shape_2d.position.y = 104
		animation_tree.set("parameters/blend_position", -1)
		_hooked_collider = null
		
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

func _update_local_hooked_collider_pos():
	_local_collider_pos = to_local(_hooked_collider.global_position)

func _calculate_equilibrium_displacement() -> Vector2:
	var equilibrium_displacement = Vector2(_equilibrium_distance - _local_collider_pos.length(), 0).rotated(_local_collider_pos.angle())
	equilibrium.points[1] = equilibrium_displacement
	return equilibrium_displacement

func _calculate_f_spring() -> Vector2:
	return -spring_constant * _calculate_equilibrium_displacement()
	
func _calculate_f_damp() -> Vector2:
	return -damping_coefficient * velocity.project(_local_collider_pos)

func _display_guide_rope() -> void:
	if _collider != null and _collider != _hooked_collider:
		rope_guide.show()
		rope_guide.points[1] = to_local(_collider.global_position)
	else:
		rope_guide.points[1] = Vector2.ZERO
		rope_guide.hide()

func _display_rope() -> void:
	if player_body_internal.position.y != 0:
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
	
var _is_jiggling = false

func _physics_process(delta):
	_update_colliding_ray_cast()
	_update_collider()
	get_input(delta)
	pointer.rotation = InputGlobals.look_angle
	vertical_state_machine.child_state_process(delta)
	vertical_state_machine.check_and_exit_child_state()
	horizontal_state_machine.check_and_exit_child_state()
	horizontal_state_machine.child_state_process(delta)
	if is_hooked:
		_update_local_hooked_collider_pos()
		var f_spring_vector: Vector2 = _calculate_f_spring()
		force_spring.points[1] = f_spring_vector
		var f_damp_vector: Vector2 = _calculate_f_damp()
		force_damp.points[1] = f_damp_vector
		
		apply_central_force(f_spring_vector, delta)
		apply_central_force(f_damp_vector, delta)
		
	#velocity.x = lerp(velocity.x, InputGlobals.move_direction.x * run_speed, 0.05)
	# apply_damping(delta)
	move_and_slide()
	if is_hooked:
		_update_local_hooked_collider_pos()
		if _lerp_amount < 1.0:
			_lerp_amount += delta * 5
			if _lerp_amount > 1.0:
				_lerp_amount = 1.0
			player_sprite_container.rotation = lerpf(_prev_rotation, _local_collider_pos.angle() + (-PI * 0.5), _lerp_amount)
			player_body_internal.position.y = lerpf(_prev_body_distance, _local_collider_pos.length() - 288, _lerp_amount)
			if _is_rehook:
				player_body.rotation = lerpf(_prev_rotation, _local_collider_pos.angle() + (-PI * 0.5), _lerp_amount)
			else:
				player_body.rotation = _local_collider_pos.angle() + (-PI * 0.5)
		else:
			player_sprite_container.rotation = _local_collider_pos.angle() + (-PI * 0.5)
			player_body_internal.position.y = _local_collider_pos.length() - 288
			player_body.rotation = _local_collider_pos.angle() + (-PI * 0.5)
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
	else:
		if _lerp_amount < 1.0:
			_lerp_amount += delta * 5
			if _lerp_amount > 1.0:
				_lerp_amount = 1.0
			player_sprite_container.rotation = lerpf(_prev_rotation, 0.0, _lerp_amount)
			player_body.rotation = lerpf(_prev_rotation, 0.0, _lerp_amount)
			player_body_internal.position.y = lerpf(_prev_body_distance, 0.0, _lerp_amount)
		else:
			player_sprite_container.rotation = 0.0 
			player_body_internal.position.y = 0.0
		if velocity.x > 0 and _flipped:
			_flipped = false
			player_sprite.apply_scale(Vector2(-1, 1))
			player_body_internal.apply_scale(Vector2(-1, 1))
		elif velocity.x < 0 and !_flipped:
			_flipped = true
			player_sprite.apply_scale(Vector2(-1, 1))
			player_body_internal.apply_scale(Vector2(-1, 1))
			
	_display_ropes()

var _flipped: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_in_air = false
	current_run_speed = ground_run_speed
	vertical_state_machine.reset()
	horizontal_state_machine.reset()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
