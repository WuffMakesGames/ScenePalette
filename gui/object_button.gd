class_name ObjectPaletteButton extends Button

enum {
	OPEN_SCENE,
	SHOW_FOLDER,
	SEP_1,
	COPY_PATH,
}

# Variables =====================================
var control: ObjectPaletteControl
var scene: String
var path: String

var gui_theme: Theme
var popup_main: PopupMenu

# Process =======================================
func _init(node: ObjectPaletteControl, label: String, icon_tex: Texture2D, root_path: String, scene_path: String) -> void:
	text = label
	icon = icon_tex
	tooltip_text = scene_path
	toggle_mode = true
	button_mask = MOUSE_BUTTON_MASK_LEFT | MOUSE_BUTTON_MASK_RIGHT
	
	# Style
	text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	custom_minimum_size = Vector2(100, 100)
	icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
	
	# Variables
	control = node
	path = root_path
	scene = scene_path

func _ready() -> void:
	gui_theme = EditorInterface.get_editor_theme()
	control.config_updated.connect(_on_config_updated)
	load_icon(scene)
	_on_config_updated()
	
	# Popup menu
	popup_main = PopupMenu.new()
	popup_main.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	popup_main.id_pressed.connect(_on_popup_item_pressed)
	popup_main.min_size = Vector2(180, 28)
	add_child(popup_main, true)
	
	# Items
	popup_main.add_icon_item(gui_theme.get_icon("Load", "EditorIcons"), "Open Scene", OPEN_SCENE)
	popup_main.add_item("Show in Filesystem", SHOW_FOLDER)
	popup_main.add_separator("", SEP_1)
	popup_main.add_icon_item(gui_theme.get_icon("ActionCopy", "EditorIcons"), "Copy Path", COPY_PATH)
	
	# Autosize
	popup_main.size = popup_main.get_contents_minimum_size()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			popup_main.position = DisplayServer.mouse_get_position()
			popup_main.show()

func _process(delta: float) -> void:
	button_pressed = control.scene_selected == scene

# Methods =======================================
func load_icon(scene_path: String) -> void:
	icon = ScenePalettePreviewGenerator.generate_preview(self, load(scene_path), Vector2(80, 80))

func _get_drag_data(at_position: Vector2) -> Variant:
	return make_data()

func _pressed() -> void:
	if control.scene_selected == scene:
		control.scene_selected = ""
	else:
		control.scene_selected = scene

# Methods =======================================
func make_data() -> Variant:
	return {files = [scene], type = "files", from_slot = get_index()}

# Signals =======================================
func _on_popup_item_pressed(id: int) -> void:
	match id:
		OPEN_SCENE: EditorInterface.open_scene_from_path(scene)
		SHOW_FOLDER: EditorInterface.get_file_system_dock().navigate_to_path(scene)
		COPY_PATH: DisplayServer.clipboard_set(scene)

func _on_config_updated() -> void:
	var color = control.config_get_color(path)
	
	# Color overrides
	remove_theme_color_override("font_hover_color")
	remove_theme_color_override("font_pressed_color")
	remove_theme_color_override("font_hover_pressed_color")
	remove_theme_color_override("icon_hover_color")
	remove_theme_color_override("icon_pressed_color")
	remove_theme_color_override("icon_hover_pressed_color")
	
	add_theme_color_override("font_hover_color", Color.WHITE)
	add_theme_color_override("font_pressed_color", Color.WHITE)
	add_theme_color_override("font_hover_pressed_color", Color.WHITE)
	add_theme_color_override("icon_hover_color", Color.WHITE)
	add_theme_color_override("icon_pressed_color", Color.WHITE)
	add_theme_color_override("icon_hover_pressed_color", Color.WHITE)
	
	# Stylebox overrides
	remove_theme_stylebox_override("normal")
	remove_theme_stylebox_override("hover")
	remove_theme_stylebox_override("focus")
	remove_theme_stylebox_override("pressed")
	remove_theme_stylebox_override("hover_pressed")
	
	var box_normal := get_theme_stylebox("normal").duplicate()
	var box_focus := get_theme_stylebox("focus").duplicate()
	var box_hover := get_theme_stylebox("hover").duplicate()
	var box_hover_pressed := get_theme_stylebox("hover_pressed").duplicate()
	var box_pressed := box_focus.duplicate()
	
	box_hover.draw_center = true
	box_pressed.draw_center = true
	box_hover_pressed.draw_center = true
	
	box_focus.border_width_left = 0
	box_focus.border_width_right = 0
	box_focus.border_width_top = 0
	box_focus.border_width_bottom = 0
	
	if color != Color.WHITE:
		box_normal.bg_color = box_normal.bg_color.blend(Color(color, 0.2))
		box_hover.bg_color = box_hover.bg_color.blend(Color(color, 0.1))
		box_focus.bg_color = box_normal.bg_color
		box_pressed.bg_color = box_normal.bg_color
		box_pressed.border_color = color
	else:
		box_pressed.border_color = Color("#eeeeee")
	
	box_hover_pressed.bg_color = box_hover.bg_color
	box_hover_pressed.border_color = box_pressed.border_color
	
	# Overrides
	#box_pressed.bg_color = box_normal.bg_color
	add_theme_stylebox_override("normal", box_normal)
	add_theme_stylebox_override("focus", box_focus)
	add_theme_stylebox_override("hover", box_hover)
	add_theme_stylebox_override("pressed", box_pressed)
	add_theme_stylebox_override("hover_pressed", box_hover_pressed)
	
