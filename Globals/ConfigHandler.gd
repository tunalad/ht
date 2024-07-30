extends Node

var config : ConfigFile = ConfigFile.new()
const SETTINGS : String = "user://settings.ini"

func _ready() -> void:
	if FileAccess.file_exists(SETTINGS):
		config.load(SETTINGS)
	
	ensure_setting("video", "fullscreen", false)
	ensure_setting("audio", "master_volume", 1.0)
	ensure_setting("misc", 	"crt_shader", true)
	ensure_setting("misc", 	"pc_humm", true)
	ensure_setting("misc", 	"hide_mouse", true)
	
	config.save(SETTINGS)

func ensure_setting(section : String, key : String, value : Variant) -> void:
	if not config.has_section_key(section, key):
		config.set_value(section, key, value)

func save_video_settings(key : String, value : Variant) -> void:
	config.set_value("video", key, value)
	config.save(SETTINGS)

func load_video_settings() -> Dictionary:
	var video_settings := {}
	
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	
	return video_settings

func save_audio_settings(key : String, value : Variant) -> void:
	config.set_value("audio", key, value)
	config.save(SETTINGS)

func load_audio_settings() -> Dictionary:
	var audio_settings := {}
	
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	
	return audio_settings

func save_misc_settings(key : String, value : Variant) -> void:
	config.set_value("misc", key, value)
	config.save(SETTINGS)

func load_misc_settings() -> Dictionary:
	var misc_settings := {}
	
	for key in config.get_section_keys("misc"):
		misc_settings[key] = config.get_value("misc", key)
	
	return misc_settings
