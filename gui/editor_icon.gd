@tool extends Button
@export var editor_icon: String = "":
	set(value):
		var gui_theme = EditorInterface.get_editor_theme()
		if gui_theme.has_icon(editor_icon, "EditorIcons"):
			icon = gui_theme.get_icon(editor_icon, "EditorIcons")
		editor_icon = value
