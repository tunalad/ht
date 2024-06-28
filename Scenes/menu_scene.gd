extends Control

@export var menu_move : AudioStreamMP3
@export var menu_select : AudioStreamMP3
@export var menu_locked : AudioStreamMP3
@export var menu_back : AudioStreamMP3
@export var menu_quit : AudioStreamMP3

@onready var MENU_MAIN = $menu_main.get_children()
@onready var MENU_SELECT = $menu_select.get_children()

#func play_sound(sound : AudioStreamMP3):
#	$AudioStreamPlayer.set_stream(sound)
#	$AudioStreamPlayer.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	# make sure the correct menu is active
	$menu_main.show()
	$menu_select.hide()
	
	# focus on the 1st button
	MENU_MAIN[0].grab_focus()
	
	# activate the selecting sound
	for btn in MENU_MAIN:
		btn.skipped_sound = true

# # # # # # # # # # # # # 
# # # # MENU MAIN # # # # 
# # # # # # # # # # # # # 

func _on_btn_start_pressed():
	Global.play_sound($AudioStreamPlayer, menu_select)
	print("start pressed")


func _on_btn_select_vol_pressed():
	Global.play_sound($AudioStreamPlayer, menu_select)
	
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


func _on_btn_quit_pressed():
	$AudioStreamPlayer.set_stream(menu_quit)
	$AudioStreamPlayer.play()
	
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
	print("and the vol1 starts playing idk")
