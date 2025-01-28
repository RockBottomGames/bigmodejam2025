class_name DebugSliders
extends MarginContainer

@onready var DEBUG_SLIDER = preload("res://UI/Testing/DebugSlider/DebugSlider.tscn")

@onready var contents_container: HBoxContainer = %ContentsContainer
@onready var top_expand_button: Button = %TopExpandButton
@onready var bottom_expand_button: Button = %BottomExpandButton
@onready var separator_container: VBoxContainer = %SeparatorContainer
@onready var full_contents_container: MarginContainer = %FullContentsContainer
@onready var slider_container: HBoxContainer = %SliderContainer
@onready var left_page_container: MarginContainer = %LeftPageContainer
@onready var right_page_container: MarginContainer = %RightPageContainer

@export var sliders: Array[DebugSlider] = []
@export var removed_sliders: Array[DebugSlider] = []
@export var is_collapsed: bool = false:
	get:
		return is_collapsed
	set(value):
		if value != is_collapsed:
			is_collapsed = value
			if contents_container != null:
				_update_collapsed_settings()

@export var is_bottom: bool = false:
	get:
		return is_bottom
	set(value):
		if value != is_bottom:
			is_bottom = value
			if contents_container != null:
				_update_location()

@export var current_page: int = 0:
	get:
		return current_page
	set(value):
		if value != current_page:
			current_page = value
			if contents_container != null:
				_update_page_data()

func _build_sliders():
	for _index in PAGE_SIZE:
		var new_slider: DebugSlider = DEBUG_SLIDER.instantiate()
		new_slider.data = null
		new_slider.hide_children()
		slider_container.add_child(new_slider)
		sliders.append(new_slider)
	sliders = sliders.filter(func(slider: DebugSlider): return slider != null)

func _hide_all_slider_children():
	for slider: DebugSlider in sliders:
		slider.data = null
		slider.hide_children()

func set_data(new_data: Array[DebugSlider.DebugSliderData]):
	if !_data.is_empty():
		_data.clear()
	_data.append_array(new_data)
	_page_count = ceil(_data.size() as float / PAGE_SIZE as float)
	current_page = 0

func _update_page_data():
	if _page_count <= 1:
		left_page_container.hide()
		right_page_container.hide()
	else:
		left_page_container.show()
		right_page_container.show()
	_display_sliders()

const PAGE_SIZE: int = 3
const SEPARATION: int = 5
var _page_count: int = 0
var _data: Array[DebugSlider.DebugSliderData] = []

func _update_collapsed_settings():
	if is_bottom:
		_update_bottom_collapsed_settings()
		return
	_update_top_collapsed_settings()

func _update_top_collapsed_settings():
	if is_collapsed:
		full_contents_container.add_theme_constant_override("margin_top", (-contents_container.size.y - top_expand_button.size.y - SEPARATION) as int)
		bottom_expand_button.text = "v"
		top_expand_button.text = "^"
	else:
		full_contents_container.add_theme_constant_override("margin_top", (-top_expand_button.size.y) as int)
		bottom_expand_button.text = "^"
		top_expand_button.text = "v"

func _update_bottom_collapsed_settings():
	if is_collapsed:
		full_contents_container.add_theme_constant_override("margin_bottom", (-contents_container.size.y - bottom_expand_button.size.y - SEPARATION) as int)
		bottom_expand_button.text = "v"
		top_expand_button.text = "^"
	else:
		full_contents_container.add_theme_constant_override("margin_bottom", (-top_expand_button.size.y) as int)
		bottom_expand_button.text = "^"
		top_expand_button.text = "v"

func _update_location():
	if is_bottom:
		full_contents_container.add_theme_constant_override("margin_top", 0)
		full_contents_container.size_flags_vertical = Control.SIZE_SHRINK_END
		_update_bottom_collapsed_settings()
		return
	full_contents_container.add_theme_constant_override("margin_bottom", 0)
	full_contents_container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_update_top_collapsed_settings()

func _exit_tree() -> void:
	GlobalReferences.debug_sliders = null

func _enter_tree() -> void:
	GlobalReferences.debug_sliders = self
	if contents_container == null:
		return
	_update_location()
	_update_page_data()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_location()
	_build_sliders()
	_update_page_data()

func _display_sliders() -> void:
	_hide_all_slider_children()
	var initial_index: int = current_page * PAGE_SIZE
	var index: int = initial_index
	while index < _data.size() and index < PAGE_SIZE + initial_index:
		var slider = sliders[index]
		slider.data = _data[index]
		slider.show_children()
		index += 1

func _on_left_page_button_down() -> void:
	if current_page > 0:
		current_page -= 1
	else :
		current_page = _page_count - 1

func _on_right_page_button_down() -> void:
	if current_page < _page_count - 1:
		current_page += 1
	else :
		current_page = 0

func _on_expand_toggle_button_button_down() -> void:
	is_collapsed = !is_collapsed
