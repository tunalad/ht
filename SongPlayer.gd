extends Control

@export var game_background : CompressedTexture2D # main background image
@export var song_name : String = "Song name" # track title that fades in and out
@export var audio_file : AudioStream # the song file
@export var text_fade: float = 4 # seconds that the text (and background) stays on the screen for
@export var song_start_delay : float = 2 # delay before the fadeout
@export var next_scene : String = "res://Scenes/MenuScene.tscn"

func _ready():
	# setup
	$GameBackground.texture = game_background
	$Intro/VBoxContainer/TrackTitle.bbcode_text = "[center] %s [/center]" % song_name
	
	# fade the text in and stay for like 2 seconds
	$AnimationPlayer.play("text_fade_in") # fades the track name in
	await get_tree().create_timer(text_fade).timeout
	
	Global.play_sound($MusicPlayer, audio_file)
	await get_tree().create_timer(song_start_delay).timeout
	$AnimationPlayer.play("fade_in") # fades into the "game" (4 seconds long animation)
	
	await get_tree().create_timer($MusicPlayer.stream.get_length() - 1.0).timeout
	
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	
	get_tree().change_scene_to_file(next_scene)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		print("going back to main menu")
		$AnimationPlayer.play("fade_out")
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://Scenes/MenuScene.tscn")
