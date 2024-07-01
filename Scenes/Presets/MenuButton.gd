@tool
extends TextureButton

@export var text: String = "Text button"
@export var arrow_margin_from_center: int = 20
var skipped_sound = false


func _ready():
	setup_text()
	setup_neighbours()
	hide_arrows()
	set_focus_mode(Control.FOCUS_ALL)

func _process(_delta):
	if Engine.is_editor_hint():
		setup_text()
		show_arrows()

func setup_text():
	$RichTextLabel.bbcode_text = "[center] %s [/center]" % text

func setup_neighbours():
	var my_pos = self.get_index()
	var parent = $"..".get_children()
	
	self.set_focus_neighbor(SIDE_TOP, parent[my_pos - 1].get_path())
	
	if my_pos + 1 >= len(parent):
		self.set_focus_neighbor(SIDE_BOTTOM, parent[0].get_path())
	else:
		self.set_focus_neighbor(SIDE_BOTTOM, parent[my_pos + 1].get_path())
	

func show_arrows():
	# Get the center position of the TextureButton
	var center_x = size.x / 2
	var center_y = size.y / 2

	for arrow in [$ArrowLeft, $ArrowRight]:
		arrow.visible = true
		arrow.position.y = center_y - arrow.size.y / 2
	
	$ArrowLeft.position.x = center_x - arrow_margin_from_center - $ArrowLeft.size.x / 2
	$ArrowRight.position.x = center_x + arrow_margin_from_center - $ArrowRight.size.x / 2
	
	if skipped_sound:
		$"../../AudioStreamPlayer".set_stream($"../..".get("menu_move"))
		$"../../AudioStreamPlayer".play()

func hide_arrows():
	for arrow in [$ArrowLeft, $ArrowRight]:
		arrow.visible = false


func _on_focus_entered():
	show_arrows()


func _on_focus_exited():
	hide_arrows()


func _on_mouse_entered():
	grab_focus()
