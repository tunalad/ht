extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$TextureRect.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var settings = ConfigHandler.load_misc_settings()
	
	if !settings["crt_shader"]:
		self.visible = false
	else:
		self.visible = true
