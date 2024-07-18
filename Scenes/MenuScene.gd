extends Control

@onready var AUDIO_PLAYER = get_tree().current_scene.get_node("AudioStreamPlayer")
@onready var MENU_MAIN = $menu_main.get_children()
@onready var MENU_SELECT = $menu_select.get_children()
@onready var MENU_OPTS = $menu_options/VBoxContainer/HBoxContainer/menu_options_left.get_children()


func _ready():
	# make sure the correct menu is active
	$menu_main.show()
	$menu_select.hide()
	$menu_options.hide()
	
	MENU_OPTS.append($menu_options/VBoxContainer/btn_opt_back)
	
	DevConsole.connect("on_terminal_closed", _on_dev_console_console_closed)
	load_settings()
	
	# focus on the 1st button (if console's closed)
	if !DevConsole.visible: 
		MENU_MAIN[0].grab_focus()
	
	# activate the selecting sound
	set_skipped_sound(MENU_MAIN, true)
	
	Global.setup_neighbours(MENU_MAIN)
	Global.setup_neighbours(MENU_SELECT)
	Global.setup_neighbours(MENU_OPTS)
	
	TransitionScreen.fade_to_normal(4)


func load_settings():
	var video_settings = ConfigHandler.load_video_settings()
	var audio_settings = ConfigHandler.load_audio_settings()
	var misc_settings = ConfigHandler.load_misc_settings()
	
	var labels = {
		"fullscreen_label": $menu_options/VBoxContainer/HBoxContainer/menu_options_right/fullscreen_indicator,
		"volume_label": $menu_options/VBoxContainer/HBoxContainer/menu_options_right/volume_indicator,
		"crt_label": $menu_options/VBoxContainer/HBoxContainer/menu_options_right/crt_indicator,
		"humm_label": $menu_options/VBoxContainer/HBoxContainer/menu_options_right/humm_indicator
	}
	
	Global.load_settings()
	
	# audio settings setup
	labels["volume_label"].text = Global.draw_bar(audio_settings["master_volume"] * 100, 10)
	
	# video settings setup
	labels["fullscreen_label"].text = "ON" if video_settings["fullscreen"] else "OFF"
	labels["crt_label"].text = "ON" if misc_settings["crt_shader"] else "OFF"
	labels["humm_label"].text = "ON" if misc_settings["pc_humm"] else "OFF"


func set_skipped_sound(buttons : Array, state : bool):
	for btn in buttons:
		btn.skipped_sound = state


# # # # # # # # # # # # #
# # # # MENU MAIN # # # #
# # # # # # # # # # # # #


func _on_btn_select_vol_pressed():
	var songs = DevConsole.load_song()
	
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])
	
	# show the selection menu instead
	$menu_main.hide()
	$menu_select.show()
	
	# locking vol1 if we can't find the scene file
	if songs == "" or !songs.split("\n").has("v1s1"):
		$menu_select/btn_vol1.text = "LOCKED"
		$menu_select/btn_vol1.arrow_margin = 47
		$menu_select/btn_vol1.setup_text()
	
	# focus on the 1st button
	MENU_SELECT[0].grab_focus()
	
	# activate sounds for menu_select items
	set_skipped_sound(MENU_SELECT, true)
	set_skipped_sound(MENU_MAIN, !true)


func _on_btn_opts_pressed():
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])
	
	# show the options menu instead
	$menu_main.hide()
	$menu_options.show()
	
	# focus on the 1st button
	MENU_OPTS[0].grab_focus()
	
	set_skipped_sound(MENU_OPTS, true)
	set_skipped_sound(MENU_MAIN, !true)


func _on_btn_quit_pressed():
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_quit"])

	TransitionScreen.transition(2, 0.5)
	await TransitionScreen.on_transition_finished

	get_tree().quit()


# # # # # # # # # # # # # #
# # # # SELECT MENU # # # #
# # # # # # # # # # # # # #


func _on_btn_back_pressed():
	Global.play_sound($AudioStreamPlayer, Global.sounds["menu_back"])
	
	# show the selection menu instead
	$menu_main.show()
	$menu_select.hide()
	
	# disable the sounds in menu_select
	set_skipped_sound(MENU_SELECT, !true)
	MENU_MAIN[0].grab_focus()
	set_skipped_sound(MENU_MAIN, true)


func _on_locked_pressed():
	Global.play_sound($AudioStreamPlayer, Global.sounds["menu_locked"])


func _on_btn_vol_1_pressed():
	var songs = DevConsole.load_song().split("\n")
	
	if !songs.has("v1s1"):
		Global.play_sound($AudioStreamPlayer, Global.sounds["menu_locked"])
		return
	
	Global.play_sound($AudioStreamPlayer, Global.sounds["menu_quit"])
	TransitionScreen.transition(2.2, 1)
	await TransitionScreen.on_transition_finished
	DevConsole.load_song("v1s1")


# # # # # # # # # # # # # #
# # #  OPTIONS MENU # # # #
# # # # # # # # # # # # # #


func _on_btn_opt_back_pressed():
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_back"])
	
	# show the selection menu instead
	$menu_main.show()
	$menu_options.hide()
	
	# disable the sounds in menu_select
	set_skipped_sound(MENU_OPTS, !true)
	MENU_MAIN[0].grab_focus()
	set_skipped_sound(MENU_MAIN, true)


func _on_btn_opt_fullscreen_pressed():
	var video_settings = ConfigHandler.load_video_settings()
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])
	ConfigHandler.save_video_settings("fullscreen", !video_settings["fullscreen"])
	load_settings()


func _on_btn_opt_vol_left_key_pressed():
	var audio_settings = ConfigHandler.load_audio_settings()
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])
	
	audio_settings["master_volume"] -= 0.1
	
	if audio_settings["master_volume"] > 1.0:
		audio_settings["master_volume"] = 1.0
	if audio_settings["master_volume"] < 0.0:
		audio_settings["master_volume"] = 0.0
	ConfigHandler.save_audio_settings("master_volume", audio_settings["master_volume"])
	load_settings()


func _on_btn_opt_vol_right_key_pressed():
	var audio_settings = ConfigHandler.load_audio_settings()
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])
	
	audio_settings["master_volume"] += 0.1
	
	if audio_settings["master_volume"] > 1.0:
		audio_settings["master_volume"] = 1.0
	if audio_settings["master_volume"] < 0.0:
		audio_settings["master_volume"] = 0.0
	ConfigHandler.save_audio_settings("master_volume", audio_settings["master_volume"])
	load_settings()


func _on_btn_opt_crt_pressed():
	var misc_settings = ConfigHandler.load_misc_settings()
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])
	ConfigHandler.save_misc_settings("crt_shader", !misc_settings["crt_shader"])
	load_settings()


func _on_btn_opt_humm_pressed():
	var misc_settings = ConfigHandler.load_misc_settings()
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])
	ConfigHandler.save_misc_settings("pc_humm", !misc_settings["pc_humm"])
	load_settings()


# # # # # # # # # # # # # #
# # # OTHER SIGNALS # # # #
# # # # # # # # # # # # # #


func _on_dev_console_console_closed():
	if $menu_main.visible:
		MENU_MAIN[0].grab_focus()
	if $menu_select.visible:
		MENU_SELECT[0].grab_focus()
	if $menu_options.visible:
		MENU_OPTS[0].grab_focus()
