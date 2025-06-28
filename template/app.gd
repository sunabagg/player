extends App

var theme: Theme

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	init_state(false)
	var args = OS.get_cmdline_args()
	var root_path : String = ProjectSettings.globalize_path("res://")
	if (!OS.has_feature("editor")):
		root_path = OS.get_executable_path().get_base_dir()
		if (OS.get_name() == "macOS"):
			root_path = root_path.replace("MacOS", "Resources")
	
	if not root_path.ends_with("/"):
		root_path += "/"
	
	var sbx_path := root_path + "player.sbx"
	
	load_and_execute_sbx(sbx_path)

func _ready() -> void:
	if (DisplayServer.is_dark_mode()):
		theme = load("res://addons/lite/dark.tres")
	else:
		theme = load("res://addons/lite/light.tres")
	get_tree().root.theme = theme
