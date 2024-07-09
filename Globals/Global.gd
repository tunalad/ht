extends Node

var loaded_vol1 = false

var sounds = {
	"menu_move": load("res://SFX/SH Menu Blip 01.mp3"),
	"menu_select": load("res://SFX/SH Menu Blip 02.mp3"),
	"menu_locked": load("res://SFX/SH Menu Blip 05.mp3"),
	"menu_back": load("res://SFX/SH Menu Blip 03.mp3"),
	"menu_quit": load("res://SFX/SH Menu Blip 04.mp3"),
}

func john():
	print("johning around")

func play_sound(node : AudioStreamPlayer, sound : AudioStream):
	node.set_stream(sound)
	node.play()

func _ready():
	if ProjectSettings.load_resource_pack("res://vol1.pck"):
		loaded_vol1 = true
