extends Control

@export var menu_move : AudioStreamMP3
@export var menu_select : AudioStreamMP3
@export var menu_locked : AudioStreamMP3
@export var menu_back : AudioStreamMP3
@export var menu_quit : AudioStreamMP3

@onready var AUDIO_PLAYER = get_tree().current_scene.get_node("AudioStreamPlayer")
@onready var MENU_MAIN = $menu_main.get_children()
@onready var MENU_SELECT = $menu_select.get_children()
@onready var MENU_OPTS = $menu_options/VBoxContainer/HBoxContainer/menu_options_left.get_children()
@onready var MENU_OPTS_BACK = $menu_options/VBoxContainer/btn_opt_back

# Called when the node enters the scene tree for the first time.
func _ready():
	# make sure the correct menu is active
	$menu_main.show()
	$menu_select.hide()
	$menu_options.hide()
	
	load_settings()
	
	# focus on the 1st button
	MENU_MAIN[0].grab_focus()
	
	# activate the selecting sound
	for btn in MENU_MAIN:
		btn.skipped_sound = true
	
	manual_neighbours_fix()
	
	TransitionScreen.fade_to_normal()
	await TransitionScreen.on_transition_finished

func load_settings():
	var video_settings = ConfigHandler.load_video_settings()
	var audio_settings = ConfigHandler.load_audio_settings()
	
	var fullscreen_label = $menu_options/VBoxContainer/HBoxContainer/menu_options_right/fullscreen_indicator
	var volume_label = $menu_options/VBoxContainer/HBoxContainer/menu_options_right/volume_indicator
	
	# video settings setup
	if video_settings["fullscreen"]:
		fullscreen_label.text = "ON"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		fullscreen_label.text = "OFF"
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	# audio settings setup
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(audio_settings["master_volume"])
	)
	volume_label.text = draw_bar(audio_settings["master_volume"]*100, 10)
	print(audio_settings["master_volume"]*100)

func draw_bar(percentage : int, bars : int = 20) -> String:
	var filled = "█ "
	var empty = "○ "
	var filled_bars = int((percentage / 100.0) * bars)
	return filled.repeat(filled_bars) + empty.repeat(bars - filled_bars)

func manual_neighbours_fix():
	# manual neighbours setup intervention because I can't be bothered figuring it out the hard way
	var btn_opt_back = $menu_options/VBoxContainer/btn_opt_back
	var btn_opt_fullscreen = $menu_options/VBoxContainer/HBoxContainer/menu_options_left/btn_opt_fullscreen
	var btn_opt_vol = $menu_options/VBoxContainer/HBoxContainer/menu_options_left/btn_opt_vol
	
	btn_opt_back.set_focus_neighbor(SIDE_BOTTOM, btn_opt_fullscreen.get_path())
	btn_opt_vol.set_focus_neighbor(SIDE_TOP, btn_opt_vol.get_path())
	btn_opt_fullscreen.set_focus_neighbor(SIDE_TOP, btn_opt_back.get_path())
	btn_opt_vol.set_focus_neighbor(SIDE_BOTTOM, btn_opt_back.get_path())

# # # # # # # # # # # # #
# # # # MENU MAIN # # # #
# # # # # # # # # # # # #

func _on_btn_select_vol_pressed():
	Global.play_sound(AUDIO_PLAYER, menu_select)

	# show the selection menu instead
	$menu_main.hide()
	$menu_select.show()

	# focus on the 1st button
	MENU_SELECT[0].grab_focus()

	# activate sounds for menu_select items
	for btn in MENU_SELECT:
		btn.skipped_sound = true

	# but disable the sound on the other ones
	for btn in MENU_MAIN:
		btn.skipped_sound = !true

func _on_btn_opts_pressed():
	Global.play_sound(AUDIO_PLAYER, menu_select)
	
	# show the options menu instead
	$menu_main.hide()
	$menu_options.show()

	# focus on the 1st button
	MENU_OPTS[0].grab_focus()

	# activate sounds for menu_options items
	for btn in MENU_OPTS:
		btn.skipped_sound = true
	MENU_OPTS_BACK.skipped_sound = true

	# but disable the sound on the other ones
	for btn in MENU_MAIN:
		btn.skipped_sound = !true

func _on_btn_quit_pressed():
	Global.play_sound(AUDIO_PLAYER, menu_quit)

	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished

	get_tree().quit()

# # # # # # # # # # # # # #
# # # # SELECT MENU # # # #
# # # # # # # # # # # # # #

func _on_btn_back_pressed():
	Global.play_sound($AudioStreamPlayer, menu_back)

	# show the selection menu instead
	$menu_main.show()
	$menu_select.hide()

	# disable the sounds in menu_select
	for btn in MENU_SELECT:
		btn.skipped_sound = !true

	# focus the 1st button
	MENU_MAIN[0].grab_focus()

	# and activate on the main
	for btn in MENU_MAIN:
		btn.skipped_sound = true

func _on_locked_pressed():
	Global.play_sound($AudioStreamPlayer, menu_locked)

func _on_btn_vol_1_pressed():
	Global.play_sound($AudioStreamPlayer, menu_quit)
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Scenes/Levels/v1s1.tscn")

# # # # # # # # # # # # # #
# # #  OPTIONS MENU # # # #
# # # # # # # # # # # # # #

func _on_btn_opt_back_pressed():
	Global.play_sound(AUDIO_PLAYER, menu_back)
	
	# show the selection menu instead
	$menu_main.show()
	$menu_options.hide()
	
	# disable the sounds in menu_select
	for btn in MENU_OPTS:
		btn.skipped_sound = !true
	MENU_OPTS_BACK.skipped_sound = !true
	
	# focus the 1st button
	MENU_MAIN[0].grab_focus()
	
	# and activate on the main
	for btn in MENU_MAIN:
		btn.skipped_sound = true

func _on_btn_opt_fullscreen_pressed():
	var video_settings = ConfigHandler.load_video_settings()
	Global.play_sound(AUDIO_PLAYER, menu_select)
	
	ConfigHandler.save_video_settings("fullscreen", !video_settings["fullscreen"])
	load_settings()


func _on_btn_opt_vol_left_key_pressed():
	var audio_settings = ConfigHandler.load_audio_settings()
	Global.play_sound(AUDIO_PLAYER, menu_select)
	
	audio_settings["master_volume"] -= 0.1
	
	if audio_settings["master_volume"] > 1.0:
		audio_settings["master_volume"] = 1.0
	if audio_settings["master_volume"] < 0.0:
		audio_settings["master_volume"] = 0.0
	ConfigHandler.save_audio_settings("master_volume", audio_settings["master_volume"])
	load_settings()


func _on_btn_opt_vol_right_key_pressed():
	var audio_settings = ConfigHandler.load_audio_settings()
	Global.play_sound(AUDIO_PLAYER, menu_select)
	
	audio_settings["master_volume"] += 0.1
	
	if audio_settings["master_volume"] > 1.0:
		audio_settings["master_volume"] = 1.0
	if audio_settings["master_volume"] < 0.0:
		audio_settings["master_volume"] = 0.0
	ConfigHandler.save_audio_settings("master_volume", audio_settings["master_volume"])
	load_settings()
