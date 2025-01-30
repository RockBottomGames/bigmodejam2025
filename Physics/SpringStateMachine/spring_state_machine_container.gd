extends Node2D
class_name SpringStateMachineContainer

signal on_enter_unhooked_state()
signal on_enter_lerp_to_hooked_state()
signal on_enter_hooked_state()
signal on_enter_lerp_to_rehooked_state()
signal on_enter_lerp_to_unhooked_state()

signal postprocess_unhooked_state(delta: float)
signal postprocess_lerp_to_hooked_state(delta: float, lerp_time: float)
signal postprocess_hooked_state(delta: float)
signal postprocess_lerp_to_rehooked_state(delta: float, lerp_time: float)
signal postprocess_lerp_to_unhooked_state(delta: float, lerp_time: float)

signal on_exit_unhooked_state()
signal on_exit_lerp_to_hooked_state()
signal on_exit_hooked_state()
signal on_exit_lerp_to_rehooked_state()
signal on_exit_lerp_to_unhooked_state()

@onready var spring_external_state_nodes: SpringExternalNodes = %SpringExternalStateNodes
@onready var spring_state_machine: StateMachine = %SpringStateMachine

var spring_external_data: SpringExternalData = null:
	get:
		return (spring_state_machine.data as SpringExternalData)

var _spring: SpringData = null
@export var spring: SpringData = null:
	get:
		return _spring
	set(value):
		_spring = value
		if spring_state_machine != null:
			spring_external_data.spring = value

var _spring_object: SpringObjectData = null
@export var spring_object: SpringObjectData = null:
	get:
		return _spring_object
	set(value):
		_spring_object = value
		if spring_external_state_nodes != null:
			spring_external_state_nodes.spring_object = value

var _rotation_node: Node2D = null
@export var rotation_node: Node2D = null:
	get:
		return _rotation_node
	set(value):
		_rotation_node = value
		if spring_external_state_nodes != null:
			spring_external_state_nodes.rotation_node = value

func _setup():
	spring_external_data.spring = _spring
	spring_external_state_nodes.spring_object = _spring_object
	spring_external_state_nodes.rotation_node = _rotation_node

@export var lerp_speed: float = 5.0:
	get:
		return spring_external_data.lerp_speed
	set(value):
		spring_external_data.lerp_speed = value

@export var hooked_rotation: float = -PI * 0.5:
	get:
		return spring_external_data.hooked_rotation
	set(value):
		spring_external_data.hooked_rotation = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
