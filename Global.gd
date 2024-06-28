extends Node

func john():
	print("johning around")

func play_sound(node : AudioStreamPlayer, sound : AudioStreamMP3):
	node.set_stream(sound)
	node.play()
