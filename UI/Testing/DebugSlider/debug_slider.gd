extends MarginContainer
class_name DebugSlider

@onready var _title_label: Label = %Title
@onready var slider_node: HSlider = %Slider
@onready var _current_label: Label = %Current
@onready var _minimum_label: Label = %Minimum
@onready var _maximum_label: Label = %Maximum
@onready var _contents_container: VBoxContainer = $ContentsContainer

class DebugSliderData extends Resource:
	@export var title: String = "Placeholder Title"
	@export var current: float = 1.0
	@export var minimum: float = 0.01
	@export var maximum: float = 10000.00
	@export var step: float = 0.01
	
	func _init(
		title_: String = "Placeholder Title",
		current_: float = 1,
		minimum_: float = 0.01,
		maximum_: float = 10000.00,
		step_: float = 0.01
	):
		title = title_
		current = current_
		minimum = minimum_
		maximum = maximum_
		step = step_

func _set_nodes_from_data():
	_title_label.text = data.title
	_current_label.text = "%f" % data.current
	_minimum_label.text = "%f" % data.minimum
	_maximum_label.text = "%f" % data.maximum
	
	slider_node.value = data.current
	slider_node.min_value = data.minimum
	slider_node.max_value = data.maximum
	slider_node.step = data.step

var _DEFAULT_DATA: DebugSliderData = DebugSliderData.new()
var _data: DebugSliderData = null
@export var data: DebugSliderData = null:
	get:
		return _data if _data != null else _DEFAULT_DATA
	set(value):
		_data = value
		if _title_label != null:
			_set_nodes_from_data()

@export var value: float = 1.0:
	get:
		return slider_node.value

@export var hidden_children: bool = false:
	get:
		return hidden_children
	set(value):
		if value != hidden_children:
			hidden_children = value
			if _current_label != null:
				_set_children_hidden_from_flag()

func _set_children_hidden_from_flag():
	if hidden_children:
		_contents_container.hide()
	else:
		_contents_container.show()

func _enter_tree() -> void:
	if _title_label == null:
		return
	_set_nodes_from_data()
	_set_children_hidden_from_flag()

func _ready() -> void:
	_set_nodes_from_data()
	_set_children_hidden_from_flag()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	data.current = slider_node.value
	_current_label.text = "%f" % slider_node.value

func _init(data_: DebugSliderData = DebugSliderData.new()):
	data = data_

func hide_children() -> void:
	hidden_children = true

func show_children() -> void:
	hidden_children = false
	
