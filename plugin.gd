@tool extends EditorPlugin

# Variables =====================================
var control: Control
var control_scene: PackedScene = preload("res://addons/scene-palette/gui/control.tscn")

# Plugin ========================================
func _enter_tree() -> void:
	control = control_scene.instantiate()
	add_control_to_bottom_panel(control, "Scene Palette")
	
func _exit_tree() -> void:
	remove_control_from_bottom_panel(control)
	if control: control.queue_free()
