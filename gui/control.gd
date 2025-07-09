@tool class_name ObjectPaletteControl extends Control
signal config_updated

# Export ========================================
@export var paths_list: ObjectPaletteFileList
@export var tab_container: TabContainer

# Variables =====================================
var file_dialog: EditorFileDialog
var editor_theme: Theme
var scene_selected: String

var settings = ConfigFile.new()
var SETTINGS_PATH = "res://addons/.configs/scene-palette.cfg"

# Config ========================================
var config_paths: Array
var config_colors: Dictionary

func config_add_path(path: String) -> void:
	if config_paths.count(path) == 0:
		config_paths.append(path)
		config_save(true)

func config_remove_path(path: String) -> void:
	if config_paths.count(path) != 0:
		config_paths.remove_at(config_paths.find(path))
		config_save(true)

func config_set_color(path: String, color: Color):
	config_colors[path] = color
	config_save()

func config_get_color(path: String) -> Color:
	return config_colors.get(path, Color.WHITE)

func config_load(do_refresh: bool = false) -> void:
	settings.load(SETTINGS_PATH)
	config_paths = settings.get_value("USER", "PATHS", [])
	config_colors = settings.get_value("USER", "COLOR", {})
	if do_refresh: refresh()

func config_save(do_refresh: bool = false) -> void:
	settings.set_value("USER", "PATHS", config_paths)
	settings.set_value("USER", "COLOR", config_colors)
	settings.save(SETTINGS_PATH)
	
	emit_signal("config_updated")
	if do_refresh: refresh()
	
# Process =======================================
func _enter_tree() -> void:
	paths_list = $HSplitContainer/PathList/List/ScrollContainer/ItemList
	editor_theme = EditorInterface.get_editor_theme()
	
	# Reload
	var dir = ProjectSettings.globalize_path(SETTINGS_PATH.get_base_dir())
	DirAccess.make_dir_recursive_absolute(dir)
	config_load(true)
	
	# File dialog
	file_dialog = EditorFileDialog.new()
	file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	file_dialog.dir_selected.connect(_on_file_dialog_dir_selected)
	
	# Window
	var display = DisplayServer.get_display_safe_area()
	file_dialog.exclusive = false
	file_dialog.always_on_top = true
	file_dialog.transient = false
	file_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	file_dialog.size = display.size * 0.5
	
	# Add node
	add_child(file_dialog)
	
func _exit_tree() -> void:
	file_dialog.queue_free()

# Methods =======================================
func refresh() -> void:
	for child in tab_container.get_children(): child.free()
	paths_list.clear()
	
	# Load directories
	var icon_folder = editor_theme.get_icon("Folder", "EditorIcons")
	var tab_group_all = new_tab_group("All")
	
	for path in config_paths:
		var item = paths_list.add_item(path, icon_folder)
		var color = config_get_color(path)
		paths_list.set_item_color(item, color)
		load_directory(new_tab_group(path.get_file()), path)
		load_directory(tab_group_all, path)
	refresh_gui()

func new_tab_group(title: String) -> Node:
	var scroll = ScrollContainer.new()
	scroll.name = title
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_child(scroll)
	
	var scroll_child = HFlowContainer.new()
	scroll_child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_child.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(scroll_child)
	
	return scroll_child

func refresh_gui() -> void:
	pass

func load_directory(into: Node, dir: String) -> void:
	
	# Subdirectories
	for subdir in DirAccess.get_directories_at(dir):
		load_directory(into, dir + "/" + subdir)
	
	# Add scenes to container
	var icon = editor_theme.get_icon("PackedScene", "EditorIcons")
	for fname in DirAccess.get_files_at(dir):
		if fname.get_extension() == "tscn":
			var scene_path = dir + "/" + fname
			var button = ObjectPaletteButton.new(self, fname, icon, dir, scene_path)
			into.call_deferred("add_child", button)

# Signals =======================================
func _on_file_dialog_dir_selected(dir: String) -> void:
	config_add_path(dir)

func _on_add_pressed() -> void:
	file_dialog.visible = true

func _on_remove_pressed() -> void:
	for index in paths_list.get_selected_items():
		config_remove_path(paths_list.get_item_text(index))

func _on_refresh_pressed() -> void:
	refresh()
