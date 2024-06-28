extends Node

func john():
	print("johning around")

func play_sound(node : AudioStreamPlayer, sound : AudioStream):
	node.set_stream(sound)
	node.play()
