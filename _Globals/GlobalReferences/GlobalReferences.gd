extends Node

var rng = RandomNumberGenerator.new()

var camera: Camera2D = null

var scene_manager: SceneManager = null

#================================ DEBUG SLIDERS ==============================#

var _debug_sliders_data: Dictionary = {}:
	get:
		return _debug_sliders_data
	set(value):
		if value == null:
			return
		_debug_sliders_data = value
		if debug_sliders != null:
			_set_slider_data()

func _set_slider_data():
	var arr: Array[DebugSlider.DebugSliderData]
	arr.assign(_debug_sliders_data.values())
	debug_sliders.set_data(arr)

func add_debug_slider_data(data: DebugSlider.DebugSliderData) -> void:
	if data == null:
		return
	_debug_sliders_data[data.title] = data

func add_debug_sliders_data(data: Array[DebugSlider.DebugSliderData]) -> void:
	if data == null:
		return
	for datum in data:
		add_debug_slider_data(datum)

func remove_debug_slider_data_by_title(title: String) -> void:
	_debug_sliders_data.erase(title)

func remove_debug_slider_data(data: DebugSlider.DebugSliderData) -> void:
	if data == null:
		return
	remove_debug_slider_data_by_title(data.title)

func remove_debug_sliders_data(data: Array[DebugSlider.DebugSliderData]) -> void:
	if data == null:
		return
	for datum in data:
		remove_debug_slider_data(datum)

var debug_sliders: DebugSliders = null:
	get:
		return debug_sliders
	set(value):
		debug_sliders = value
		if debug_sliders != null:
			_set_slider_data()
