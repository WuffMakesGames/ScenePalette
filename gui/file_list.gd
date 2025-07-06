@tool class_name ObjectPaletteFileList extends ItemList

enum {
	ADD_NEW_FOLDER,
	REMOVE_FOLDER,
	SEP_1,
	SET_COLOR,
	COPY_PATH,
}

enum COLOR {
	DEFAULT, SEP, RED, ORANGE, YELLOW, GREEN, TEAL, BLUE, PURPLE, PINK, GRAY
}

# Variables =====================================
@export var control: ObjectPaletteControl
var popup_main: PopupMenu
var popup_color: PopupMenu
var gui_theme: Theme

# Process =======================================
func _ready() -> void:
	gui_theme = EditorInterface.get_editor_theme()
	item_clicked.connect(_on_item_clicked)
	allow_rmb_select = true
	
	# Popups
	popup_main = PopupMenu.new()
	popup_main.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	popup_main.min_size = Vector2(180, 28)
	popup_main.index_pressed.connect(_on_popup_main_pressed)
	add_child(popup_main, true)
	
	popup_color = PopupMenu.new()
	popup_color.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE
	popup_color.min_size = Vector2(180, 28)
	popup_color.index_pressed.connect(_on_popup_color_pressed)
	
	# Main
	popup_main.add_icon_item(editor_icon("Add"), " Add New Folder", ADD_NEW_FOLDER)
	popup_main.add_icon_item(editor_icon("Remove"), " Remove From List", REMOVE_FOLDER)
	popup_main.add_separator("", SEP_1)
	popup_main.add_submenu_node_item("Set Folder Color...", popup_color, SET_COLOR)
	popup_main.set_item_icon(SET_COLOR, editor_icon("Paint"))
	popup_main.add_icon_item(editor_icon("ActionCopy"), "Copy Path", COPY_PATH)
	
	# Colors (submenu)
	var icon_folder = editor_icon("Folder")
	add_icon_item_colored(popup_color, icon_folder, "Default (Reset)", COLOR.DEFAULT, Color(0.424, 0.729, 0.878))
	popup_color.add_separator("", COLOR.SEP)
	add_icon_item_colored(popup_color, icon_folder, "Red", COLOR.RED, Color(0.878, 0.239, 0.239))
	add_icon_item_colored(popup_color, icon_folder, "Orange", COLOR.ORANGE, Color(0.878, 0.494, 0.239))
	add_icon_item_colored(popup_color, icon_folder, "Yellow", COLOR.YELLOW, Color(0.878, 0.78, 0.239))
	add_icon_item_colored(popup_color, icon_folder, "Green", COLOR.GREEN, Color(0.439, 0.878, 0.239))
	add_icon_item_colored(popup_color, icon_folder, "Teal", COLOR.TEAL, Color(0.239, 0.878, 0.557))
	add_icon_item_colored(popup_color, icon_folder, "Blue", COLOR.BLUE, Color(0.239, 0.741, 0.878))
	add_icon_item_colored(popup_color, icon_folder, "Purple", COLOR.PURPLE, Color(0.439, 0.239, 0.878))
	add_icon_item_colored(popup_color, icon_folder, "Pink", COLOR.PINK, Color(0.878, 0.239, 0.518))
	add_icon_item_colored(popup_color, icon_folder, "Gray", COLOR.GRAY, Color(0.541, 0.541, 0.541))

	# Autosize
	popup_main.size = popup_main.get_contents_minimum_size()
	popup_color.size = popup_color.get_contents_minimum_size()

# Methods =======================================
func add_icon_item_colored(popup: PopupMenu, icon: Texture2D, label: String, id: int, color: Color = Color.WHITE):
	popup.add_icon_item(icon, label, id)
	popup.set_item_icon_modulate(id, color)

func editor_icon(name: StringName):
	return gui_theme.get_icon(name, "EditorIcons")

func set_item_color(idx: int, color: Color) -> void:
	if color == Color.WHITE:
		set_item_icon_modulate(idx, color)
		set_item_custom_bg_color(idx, Color.TRANSPARENT)
	else:
		set_item_icon_modulate(idx, color)
		set_item_custom_bg_color(idx, Color(color, 0.1))

# Signals =======================================
func _on_item_clicked(index: int, at_position: Vector2, mouse_button_index: int):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		var popup_size = popup_main.get_contents_minimum_size()
		var mouse_pos = DisplayServer.mouse_get_position()
		var screen_rect = DisplayServer.get_display_safe_area()
		popup_main.position = mouse_pos.clamp(screen_rect.position, Vector2(screen_rect.end) - popup_size)
		popup_main.show()

func _on_popup_main_pressed(id: int) -> void:
	match id:
		ADD_NEW_FOLDER: control._on_add_pressed()
		REMOVE_FOLDER: control._on_remove_pressed()
		COPY_PATH:
			for item in get_selected_items():
				DisplayServer.clipboard_set(get_item_text(item))

func _on_popup_color_pressed(id: int) -> void:
	var color = popup_color.get_item_icon_modulate(id)
	for item in get_selected_items():
		var path = get_item_text(item)
		if id == COLOR.DEFAULT:
			control.config_set_color(path, Color.WHITE)
			set_item_color(item, Color.WHITE)
		else:
			control.config_set_color(path, color)
			set_item_color(item, color)
