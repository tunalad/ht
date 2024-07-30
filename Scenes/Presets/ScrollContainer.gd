extends ScrollContainer
var max_scroll_length : float = 0
@onready var scrollbar := get_v_scroll_bar()

func _ready() -> void:
	scrollbar.changed.connect(handle_scrollbar_changed)
	max_scroll_length = scrollbar.max_value

func handle_scrollbar_changed() -> void: 
	if max_scroll_length != scrollbar.max_value: 
		max_scroll_length = scrollbar.max_value 
		self.scroll_vertical = int(max_scroll_length)
