extends Node

var sounds := {}
var found_vol1 := false

var sh_sounds := {
	"menu_move": 	load("res://SFX/sh/SH Menu Blip 01.mp3"),
	"menu_select": 	load("res://SFX/sh/SH Menu Blip 02.mp3"),
	"menu_locked": 	load("res://SFX/sh/SH Menu Blip 05.mp3"),
	"menu_back": 	load("res://SFX/sh/SH Menu Blip 03.mp3"),
	"menu_quit": 	load("res://SFX/sh/SH Menu Blip 04.mp3"),
}

var homemade_sounds := {
	"menu_move": 	load("res://SFX/homemade/select_fr03.wav"),
	"menu_select": 	load("res://SFX/homemade/select02.wav"),
	"menu_locked": 	load("res://SFX/homemade/lock02.wav"),
	"menu_back": 	load("res://SFX/homemade/back02.wav"),
	"menu_quit": 	load("res://SFX/homemade/quit04.wav"),
}

func _ready() -> void:
	sounds = homemade_sounds
	
	var success := ProjectSettings.load_resource_pack("res://vol1.pck")
	
	if success or DevConsole.load_song().split("\n").has("v1s1"):
		found_vol1 = true
		
		SceneGenerator.volumes_generator()
		
		DevConsole.echo("Volume 1 loaded.")
		
	load_customs()


func play_sound(node : AudioStreamPlayer, sound : AudioStream) -> void:
	node.set_stream(sound)
	node.play()


func load_settings() -> void:
	var video_settings := ConfigHandler.load_video_settings()
	var audio_settings := ConfigHandler.load_audio_settings()
	var misc_settings := ConfigHandler.load_misc_settings()
	
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


func draw_bar(percentage : int, bars : int = 20, extra_bar : bool = false) -> String:
	var filled := "█ "
	#var empty := "○ "
	var empty := "- "
	var filled_bars := int((percentage / 100.0) * bars)
	
	if extra_bar:
		filled_bars += 1
	
	if filled_bars > bars:
		filled_bars = bars
	
	return filled.repeat(filled_bars) + empty.repeat(bars - filled_bars)


func setup_neighbours(buttons : Array, is_horizontal : bool = false) -> void:
	var top := SIDE_TOP
	var bottom := SIDE_BOTTOM
	
	if is_horizontal:
		top = SIDE_LEFT
		bottom = SIDE_RIGHT
	
	for b : TextureButton in buttons:
		var my_pos := buttons.find(b, 0)
		
		if not is_instance_valid(b.focus_neighbor_top):
			b.set_focus_neighbor(top, buttons[my_pos - 1].get_path())
		
		if not is_instance_valid(b.focus_neighbor_bottom):
			if my_pos + 1 >= len(buttons):
				b.set_focus_neighbor(bottom, buttons[0].get_path())
			else:
				b.set_focus_neighbor(bottom, buttons[my_pos + 1].get_path())


func load_customs() -> void:
	var exec_path := OS.get_executable_path()
	var custom_folder_path := exec_path.get_base_dir().replace(exec_path, "") + "/customs"
	
	if DirAccess.dir_exists_absolute(custom_folder_path):
		var dir := DirAccess.open(custom_folder_path)
		
		if dir != null:
			dir.list_dir_begin()
			
			while true:
				var filename := dir.get_next()
				if filename == "": break
				
				if filename.ends_with(".pck"):
					DevConsole.echo("Loaded %s" % filename)
					ProjectSettings.load_resource_pack(custom_folder_path + "/" + filename)
			
			SceneGenerator.customs_generator()
		else:
			print("Failed to open `custom` folder.")
