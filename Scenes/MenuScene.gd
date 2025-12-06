# Copyright (c) 2025 tunalad
# SPDX-License-Identifier: BSD-2-Clause
# See LICENSE file for details
extends Control

@onready var AUDIO_PLAYER := get_tree().current_scene.get_node("AudioStreamPlayer")
@onready var MENU_MAIN := $menu_main.get_children()
@onready var MENU_SELECT := $menu_select.get_children()
@onready var MENU_OPTS := $menu_options/VBoxContainer/HBoxContainer/menu_options_left.get_children()
@onready var BACKGROUND := $Background


func _ready() -> void:
	# make sure the correct menu is active
	$menu_main.show()
	$menu_select.hide()
	$menu_options.hide()

	MENU_OPTS.append($menu_options/VBoxContainer/btn_opt_back)

	DevConsole.connect("on_terminal_closed", _on_dev_console_console_closed)
	load_settings()

	if !Global.found_vol1:
		vol_missing_warn()

	# focus on the 1st button (if console's closed)
	if !DevConsole.visible:
		MENU_MAIN[0].grab_focus()

	# activate the selecting sound
	set_skipped_sound(MENU_MAIN, true)

	Global.setup_neighbours(MENU_MAIN)
	Global.setup_neighbours(MENU_SELECT)
	Global.setup_neighbours(MENU_OPTS)

	# locking vol1 if we can't find the scene file
	if !Global.found_vol1:
		$menu_select/btn_vol1.text = "LOCKED"
		$menu_select/btn_vol1.arrow_margin = 52
		$menu_select/btn_vol1.setup_text()

	# locking vol2 if we can't find the scene file
	if !Global.found_vol2:
		$menu_select/btn_vol2.text = "LOCKED"
		$menu_select/btn_vol2.arrow_margin = 52
		$menu_select/btn_vol2.setup_text()
	else:
		BACKGROUND.texture = load("res://GFX/ht-menu2.png")

	TransitionScreen.fade_to_normal(4)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") && !DevConsole.visible:
		if $menu_select.visible:
			_on_btn_back_pressed()
		elif $menu_options.visible:
			_on_btn_opt_back_pressed()


func load_settings() -> void:
	var video_settings := ConfigHandler.load_video_settings()
	var audio_settings := ConfigHandler.load_audio_settings()
	var misc_settings := ConfigHandler.load_misc_settings()

	var labels := {
		"fullscreen_label":
		$menu_options/VBoxContainer/HBoxContainer/menu_options_right/fullscreen_indicator,
		"volume_label":
		$menu_options/VBoxContainer/HBoxContainer/menu_options_right/volume_indicator,
		"crt_label": $menu_options/VBoxContainer/HBoxContainer/menu_options_right/crt_indicator,
		"humm_label": $menu_options/VBoxContainer/HBoxContainer/menu_options_right/humm_indicator,
		"interm_label":
		$menu_options/VBoxContainer/HBoxContainer/menu_options_right/interm_indicator
	}

	Global.load_settings()

	# audio settings setup
	labels["volume_label"].text = Global.draw_bar(audio_settings["master_volume"] * 100, 10)

	# video settings setup
	labels["fullscreen_label"].text = "ON" if video_settings["fullscreen"] else "OFF"
	labels["crt_label"].text = "ON" if misc_settings["crt_shader"] else "OFF"
	labels["humm_label"].text = "ON" if misc_settings["pc_humm"] else "OFF"
	labels["interm_label"].text = "ON" if !misc_settings["skip_interm"] else "OFF"


func vol_missing_warn() -> void:
	DevConsole.echo("vol1.pck not found next to the executable.")
	DevConsole.echo(
		"You can find vol1.pck and future volumes at https://tunalad.itch.io/helens-tapes"
	)
	DevConsole.console("open")


func set_skipped_sound(buttons: Array, state: bool) -> void:
	for btn: TextureButton in buttons:
		btn.skipped_sound = state


func update_settings_info() -> void:
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])
	load_settings()


# # # # # # # # # # # # #
# # # # MENU MAIN # # # #
# # # # # # # # # # # # #


func _on_btn_select_vol_pressed() -> void:
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])

	# show the selection menu instead
	$menu_main.hide()
	$menu_select.show()

	# focus on the latest volume
	if Global.found_vol2:
		MENU_SELECT[1].grab_focus()
	else:
		MENU_SELECT[0].grab_focus()

	# activate sounds for menu_select items
	set_skipped_sound(MENU_SELECT, true)
	set_skipped_sound(MENU_MAIN, !true)


func _on_btn_opts_pressed() -> void:
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_select"])

	# show the options menu instead
	$menu_main.hide()
	$menu_options.show()

	# focus on the 1st button
	MENU_OPTS[0].grab_focus()

	set_skipped_sound(MENU_OPTS, true)
	set_skipped_sound(MENU_MAIN, !true)


func _on_btn_quit_pressed() -> void:
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_quit"])

	TransitionScreen.transition(2, 0.5)
	await TransitionScreen.on_transition_finished

	DevConsole.quit()


# # # # # # # # # # # # # #
# # # # SELECT MENU # # # #
# # # # # # # # # # # # # #


func _on_btn_back_pressed() -> void:
	Global.play_sound($AudioStreamPlayer, Global.sounds["menu_back"])

	# show the selection menu instead
	$menu_main.show()
	$menu_select.hide()

	# disable the sounds in menu_select
	set_skipped_sound(MENU_SELECT, !true)
	MENU_MAIN[0].grab_focus()
	set_skipped_sound(MENU_MAIN, true)


func _on_locked_pressed() -> void:
	Global.play_sound($AudioStreamPlayer, Global.sounds["menu_locked"])


func _on_btn_vol_1_pressed() -> void:
	if !Global.found_vol1:
		Global.play_sound($AudioStreamPlayer, Global.sounds["menu_locked"])
		return

	Global.play_sound($AudioStreamPlayer, Global.sounds["menu_quit"])
	TransitionScreen.transition(2.2, 1)
	await TransitionScreen.on_transition_finished
	DevConsole.load_song("v1s1")


func _on_btn_vol_2_pressed() -> void:
	if !Global.found_vol2:
		Global.play_sound($AudioStreamPlayer, Global.sounds["menu_locked"])
		return

	Global.play_sound($AudioStreamPlayer, Global.sounds["menu_quit"])
	TransitionScreen.transition(2.2, 1)
	await TransitionScreen.on_transition_finished
	DevConsole.load_song("v2s1")


func _on_btn_vol_1_focus_entered() -> void:
	BACKGROUND.texture = load("res://GFX/ht-menu-8bit.png")


func _on_btn_vol_2_focus_entered() -> void:
	if Global.found_vol2:
		BACKGROUND.texture = load("res://GFX/ht-menu2.png")


# # # # # # # # # # # # # #
# # #  OPTIONS MENU # # # #
# # # # # # # # # # # # # #


func _on_btn_opt_back_pressed() -> void:
	Global.play_sound(AUDIO_PLAYER, Global.sounds["menu_back"])

	# show the selection menu instead
	$menu_main.show()
	$menu_options.hide()

	# disable the sounds in menu_select
	set_skipped_sound(MENU_OPTS, !true)
	MENU_MAIN[0].grab_focus()
	set_skipped_sound(MENU_MAIN, true)


func _on_btn_opt_fullscreen_pressed() -> void:
	DevConsole.fullscreen()
	update_settings_info()


func _on_btn_opt_vol_left_key_pressed() -> void:
	Global.decrease_vol()
	update_settings_info()


func _on_btn_opt_vol_right_key_pressed() -> void:
	Global.increase_vol()
	update_settings_info()


func _on_btn_opt_crt_pressed() -> void:
	DevConsole.crt_shader()
	update_settings_info()


func _on_btn_opt_humm_pressed() -> void:
	DevConsole.pc_humm()
	update_settings_info()


func _on_btn_opt_interm_pressed() -> void:
	DevConsole.skip_interm()
	update_settings_info()


# # # # # # # # # # # # # #
# # # OTHER SIGNALS # # # #
# # # # # # # # # # # # # #


func _on_dev_console_console_closed() -> void:
	if $menu_main.visible:
		MENU_MAIN[0].grab_focus()
	if $menu_select.visible:
		MENU_SELECT[0].grab_focus()
	if $menu_options.visible:
		MENU_OPTS[0].grab_focus()
