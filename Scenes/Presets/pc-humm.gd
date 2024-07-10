extends AudioStreamPlayer


func _process(_delta):
	var hum_disabled = ConfigHandler.load_misc_settings()["pc_humm"]
	AudioServer.set_bus_mute(2, !hum_disabled)
