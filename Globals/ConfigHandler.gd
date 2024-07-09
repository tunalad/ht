extends Node

var config = ConfigFile.new()
const SETTINGS = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS):
		config.set_value("video", "fullscreen", false)
		config.set_value("audio", "master_volume", 1.0)
		config.set_value("misc", "crt_shader", false)
		
		config.save(SETTINGS)
	else:
		config.load(SETTINGS)

func save_video_settings(key : String, value):
	config.set_value("video", key, value)
	config.save(SETTINGS)

func load_video_settings():
	var video_settings = {}
	
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	
	return video_settings

func save_audio_settings(key : String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS)

func load_audio_settings():
	var audio_settings = {}
	
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	
	return audio_settings

func save_misc_settings(key : String, value):
	config.set_value("misc", key, value)
	config.save(SETTINGS)

func load_misc_settings():
	var misc_settings = {}
	
	for key in config.get_section_keys("misc"):
		misc_settings[key] = config.get_value("misc", key)
	
	return misc_settings
