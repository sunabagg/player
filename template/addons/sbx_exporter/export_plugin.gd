extends EditorExportPlugin
class_name  SbxExportPlugin

var _plugin_name = "SbxExporter"

var export_path: String

func  _supports_platform(platform: EditorExportPlatform) -> bool:
	return true

func _get_name() -> String:
	return _plugin_name

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	var res_path = ProjectSettings.globalize_path("res://")
	if (not res_path.ends_with("/")):
		res_path += "/"
	export_path = res_path + path.get_base_dir() +"/"
	print(export_path)
	if get_export_platform() is EditorExportPlatformMacOS:
		if path.ends_with(".app"):
			export_path = res_path + path + "/Contents/Resources/"
			print(export_path)
		return
	var dir_access = DirAccess.open(res_path)
	for file in dir_access.get_files():
		if (file.ends_with(".sbx") or file.ends_with(".sblib")) or file == "mobdebug.lua":
			var filepath = res_path + file
			var fileaccess = FileAccess.open(filepath, FileAccess.READ)
			var filedata = fileaccess.get_buffer(fileaccess.get_length())
			var export_filepath = export_path + file
			print("exporting file: res://" + file + " to " + export_filepath)
			var export_fileaccess = FileAccess.open(export_filepath, FileAccess.WRITE)
			if (export_fileaccess != null):
				export_fileaccess.store_buffer(filedata)

func _export_end() -> void:
	if not get_export_platform() is EditorExportPlatformMacOS:
		return
	var dir_access = DirAccess.open(ProjectSettings.globalize_path("res://"))
	for file in dir_access.get_files():
		if (file.ends_with(".sbx") or file.ends_with(".sblib")) or file == "mobdebug.lua":
			var filepath = ProjectSettings.globalize_path("res://") + file
			var fileaccess = FileAccess.open(filepath, FileAccess.READ)
			var filedata = fileaccess.get_buffer(fileaccess.get_length())
			var export_filepath = export_path + file
			print("exporting file: res://" + file + " to " + export_filepath)
			var export_fileaccess = FileAccess.open(export_filepath, FileAccess.WRITE)
			if (export_fileaccess != null):
				export_fileaccess.store_buffer(filedata)
	
