extends Control

@export var game_background : Texture2D # main background image
@export var song_name : String = "Song name" # track title that fades in and out
@export var audio_file : AudioStream # the song file
@export var text_fade_in: float = 2 # seconds that the text (and background) stays on the screen for
@export var song_start_delay : float = 2 # delay before the fadeout
@export var fade_out : float = 4
@export var next_scene : String
@export var previous_scene : String

var song_length : float = 0.0
var song_position : float = 0.0

func _ready() -> void:
	DevConsole.connect("console_pause", pause_song)
	
	# setup
	$GameBackground.texture = game_background
	$Intro/VBoxContainer/TrackTitle.bbcode_text = "[center] %s [/center]" % song_name
	$Intro.visible = true
	$Exit.visible = true
	
	if !next_scene:
		$Controller/btn_skip.set_disabled(true)
		$Controller/btn_back/ButtonText.visible = false
	
	if !previous_scene:
		$Controller/btn_back.set_disabled(true)
		$Controller/btn_back/ButtonText.visible = false
	
	# fade the text in and stay for like 2 seconds
	$AnimationPlayer.speed_scale = $AnimationPlayer.get_animation("text_fade_in").length / text_fade_in
	$AnimationPlayer.play("text_fade_in") # fades the track name in
	
	$MusicPlayer.stream = audio_file
	song_length = $MusicPlayer.stream.get_length()
	
	$SongTimer.start(song_start_delay)
	await $SongTimer.timeout
	
	Global.play_sound($MusicPlayer, audio_file)
	
	$SongTimer.start(4)
	await $SongTimer.timeout
	$AnimationPlayer.play("fade_in") # fade in
	
	#await get_tree().create_timer($MusicPlayer.stream.get_length() - fade_out * 2.0).timeout
	$SongTimer.start(song_length - (fade_out * 2.0))
	await $SongTimer.timeout
	
	TransitionScreen.transition(fade_out, fade_out / 2.0)
	await TransitionScreen.on_transition_finished
	
	if (next_scene):
		DevConsole.load_song(next_scene)
	else:
		DevConsole.menu()


func _input(event : InputEvent) -> void:
	if DevConsole.visible:
		return
	
	if event.is_action_pressed("ui_cancel"):
		TransitionScreen.transition(1, 0.5)
		await TransitionScreen.on_transition_finished
		DevConsole.menu()
	
	if event.is_action_pressed("song_back"):
		_on_btn_back_pressed()
	
	if event.is_action_pressed("song_skip"):
		_on_btn_skip_pressed()
	
	if event.is_action_pressed("ui_pause"):
		pause_song()
	
	if $Pause.visible:
		if event.is_action_pressed("rewind_back"):
			$Rewind.play()
		
		if event.is_action_pressed("rewind_forth"):
			$Rewind.play()
		
		if event.is_action_released("rewind_back") or event.is_action_released("rewind_forth"):
			rewind_song(true)
			$Rewind.stop()


func _process(_delta : float) -> void:
	if $MusicPlayer.stream:
		var playback_position : float = $MusicPlayer.get_playback_position()
		
		$Controller/Timeline.text = "| %s|" % Global.draw_bar(track_percentage(), 20, true)
		$Controller/TimeLeft.text = format_timer(playback_position)
		$Controller/TimeRight.text = format_timer(song_length)
	
	if Input.is_action_pressed("rewind_back"):
		rewind_song(false, false)
	elif Input.is_action_pressed("rewind_forth"):
		rewind_song(false, true)


func track_percentage() -> int:
	if $MusicPlayer.stream:
		#`var song_length = $MusicPlayer.stream.get_length()
		var playback_position : float = $MusicPlayer.get_playback_position()
		return int((playback_position / song_length) * 100)
	else:
		return 0


func format_timer(time_seconds: float) -> String:
	var minutes := time_seconds / 60
	var seconds := int(time_seconds) % 60
	return "%02d:%02d" % [minutes, seconds]


func pause_song() -> void:
	$Pause.visible = !$Pause.visible
	$MusicPlayer.stream_paused = $Pause.visible
	$SongTimer.paused = $Pause.visible
	
	if $Pause.visible:
		TransitionScreen.animation_player.speed_scale = 0
	else:
		TransitionScreen.transition(fade_out, fade_out / 2.0)


func rewind_song(stop : bool = false, forwards : bool = false) -> void:
	if stop:
		$Pause/Label.text = "||"
		return
	
	song_position = $MusicPlayer.get_playback_position()
	
	if forwards:
		$Pause/Label.text = ">> REWINDING >>"
		song_position += .25
		if song_length > song_length:
			song_position = song_length
	elif !forwards:
		$Pause/Label.text = "<< REWINDING <<"
		song_position -= .25
		if song_position < 0.0:
			song_position = 0.0
		
	$SongTimer.wait_time = song_length - (fade_out * 2.0)
	$MusicPlayer.play(song_position)
	$MusicPlayer.stream_paused = true


func _on_btn_back_pressed() -> void:
	if previous_scene:
		DevConsole.load_song(previous_scene)


func _on_btn_skip_pressed() -> void:
	if next_scene:
		DevConsole.load_song(next_scene)


func _on_music_player_finished() -> void:
	$MusicPlayer.stream = null
	$Controller/Timeline.text = "| %s|" % Global.draw_bar(100, 20, true)
	$Controller/TimeLeft.text = format_timer(song_length)
	$Controller/TimeRight.text = format_timer(song_length)
