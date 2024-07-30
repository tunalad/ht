extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.visible = false

func toggle_crt()  -> void:
	var misc_settings := ConfigHandler.load_misc_settings()
	
	if !misc_settings["crt_shader"]:
		self.visible = false
	else:
		self.visible = true
