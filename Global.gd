extends Node

var loaded_vol1 = false

func john():
	print("johning around")

func play_sound(node : AudioStreamPlayer, sound : AudioStream):
	node.set_stream(sound)
	node.play()

func _ready():
	if ProjectSettings.load_resource_pack("res://vol1.pck"):
		loaded_vol1 = true
