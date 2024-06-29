extends Control

@export var game_background : CompressedTexture2D # main background image
@export var song_name : String = "Song name" # track title that fades in and out
@export var audio_file : AudioStream # the song file
@export var text_fade: float = 4 # seconds that the text (and background) stays on the screen for
@export var song_start_delay : float = 2 # delay before the fadeout
@export var next_scene : PackedScene

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
	
	#TransitionScreen.transition()
	#await TransitionScreen.on_transition_finished
	
	get_tree().change_scene_to_packed(next_scene)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		print("going back to main menu")
		$AnimationPlayer.play("fade_out")
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://Scenes/MenuScene.tscn")
	
	if $MusicPlayer.stream:
		var percentage = track_percentage()
		var playback_position = $MusicPlayer.get_playback_position()
		var song_length = $MusicPlayer.stream.get_length()
		var timer_text = format_timer(playback_position)
		$Timeline.bbcode_text = "[center] %s | %s | %s [/center]" % [timer_text, draw_bar(percentage), format_timer(song_length)]


func track_percentage():
	if $MusicPlayer.stream:
		var song_length = $MusicPlayer.stream.get_length()
		var playback_position = $MusicPlayer.get_playback_position()
		return int((playback_position / song_length) * 100)
	else:
		return 0

func format_timer(time_seconds: float) -> String:
	var minutes = int(time_seconds) / 60
	var seconds = int(time_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]


func draw_bar(percentage : int, bars : int = 20) -> String:
	var filled = "█ "
	var empty = "○ "
	var filled_bars = int((percentage / 100.0) * bars)
	return filled.repeat(filled_bars) + empty.repeat(bars - filled_bars)
