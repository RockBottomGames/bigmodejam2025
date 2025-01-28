extends ExternalStateData
class_name VerticalExternalData

@export var gravity_force: Vector2 = ProjectSettings.get_setting_with_override("physics/2d/default_gravity") * ProjectSettings.get_setting_with_override("physics/2d/default_gravity_vector")
@export var is_in_air: bool = false
