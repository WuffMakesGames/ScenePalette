@tool extends Button

func _enter_tree() -> void:
	var gui_theme = EditorInterface.get_editor_theme()
	expand_icon = true
	icon = gui_theme.get_icon("SnapGrid", "EditorIcons")
