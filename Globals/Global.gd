extends Node

var sounds = null

var sh_sounds = {
	"menu_move": 	load("res://SFX/sh/SH Menu Blip 01.mp3"),
	"menu_select": 	load("res://SFX/sh/SH Menu Blip 02.mp3"),
	"menu_locked": 	load("res://SFX/sh/SH Menu Blip 05.mp3"),
	"menu_back": 	load("res://SFX/sh/SH Menu Blip 03.mp3"),
	"menu_quit": 	load("res://SFX/sh/SH Menu Blip 04.mp3"),
}

var homemade_sounds = {
	"menu_move": 	load("res://SFX/homemade/select_fr03.wav"),
	"menu_select": 	load("res://SFX/homemade/select02.wav"),
	"menu_locked": 	load("res://SFX/homemade/lock02.wav"),
	"menu_back": 	load("res://SFX/homemade/back02.wav"),
	"menu_quit": 	load("res://SFX/homemade/quit04.wav"),
}

func _ready():
	sounds = homemade_sounds
	
	print(DevConsole)
	
	if ProjectSettings.load_resource_pack("res://vol1.pck"):
		print("vol1.pck found")
		DevConsole.echo("vol1.pck found.")
	
	if DevConsole.load_song().split("\n").has("v1s1"):
		print("Volume 1 loaded.")
		DevConsole.echo("Volume 1 loaded.")


func john():
	print("johning around")


func play_sound(node : AudioStreamPlayer, sound : AudioStream):
	node.set_stream(sound)
	node.play()


func load_settings():
	var video_settings = ConfigHandler.load_video_settings()
	var audio_settings = ConfigHandler.load_audio_settings()
	var misc_settings = ConfigHandler.load_misc_settings()
	
	# video settings setup
	if video_settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# audio settings setup
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(audio_settings["master_volume"])
	)
	
	# misc settings setup
	Crt.toggle_crt()
	AudioServer.set_bus_mute(2, !misc_settings["pc_humm"])
	
	if !misc_settings["hide_mouse"]:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	else:
		DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)


func draw_bar(percentage : int, bars : int = 20) -> String:
	var filled = "█ "
	var empty = "○ "
	var filled_bars = int((percentage / 100.0) * bars)
	return filled.repeat(filled_bars) + empty.repeat(bars - filled_bars)
