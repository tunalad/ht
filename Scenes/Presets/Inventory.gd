extends Control

@export var pocket_items : Array[InventoryItem]
@export var backpack_items : Array[InventoryItem]

var inventory_dict : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DevConsole.connect("on_terminal_closed", _on_dev_console_console_closed)
	DevConsole.connect("on_inventory_closed", _on_inventory_closed)
	DevConsole.connect("on_inventory_opened", _on_inventory_opened)
	DevConsole.connect("on_inventory_toggle", _on_inventory_toggle)
	
	$".".visible = false
	
	populate_pockets()
	populate_backpack()
	$GridPocket/PocketPos1.grab_focus()


func _input(event: InputEvent) -> void:
	if $".".visible and event is InputEventKey and event.is_released():
		print(get_focused_node_name())
		# description handling
		if inventory_dict.has(get_focused_node_name()):
			var now_focused : Dictionary = inventory_dict[get_focused_node_name()]
			if now_focused:
				$DescBox/MarginContainer/VBoxContainer/Label.text = now_focused.title + " - "  + now_focused.description
		else:
			$DescBox/MarginContainer/VBoxContainer/Label.text = ""


func populate_pockets() -> void:
	for item in pocket_items.size():
		print(item)
		if pocket_items[item]:
			print("add `", pocket_items[item].title, "` to the pocket")
			var grid_item_name : String = "PocketPos%d" % (item + 1)
			var grid_item := $GridPocket.get_node(grid_item_name)
			grid_item.text = pocket_items[item].title
			#grid_item.text = str(item)
			inventory_dict[grid_item_name] = {
				"title": pocket_items[item].title,
				"description": pocket_items[item].description
			}

func populate_backpack() -> void:
	for item in backpack_items.size():
		print(item)
		if backpack_items[item]:
			print("add `", backpack_items[item].title, "` to the backpack")
			var grid_item_name : String = "BpPos%d" % (item + 1)
			var grid_item := $GridBackpack.get_node(grid_item_name)
			grid_item.text = backpack_items[item].title
			#grid_item.text = str(item)
			inventory_dict[grid_item_name] = {
				"title": backpack_items[item].title,
				"description": backpack_items[item].description
			}


func get_focused_node_name() -> String:
	var focused_control := get_viewport().gui_get_focus_owner()
	if focused_control:
		return focused_control.name
	return ""


func _on_dev_console_console_closed() -> void:
	$GridPocket/PocketPos1.grab_focus()
	pass
	
func _on_inventory_closed() -> void:
	print("do sth when we close the inv idk")
	$".".visible = false
	pass

func _on_inventory_opened() -> void:
	print("do sth when we open the inv idk")
	$".".visible = true
	DevConsole.console("close")

func _on_inventory_toggle() -> void:
	if $".".visible:
		_on_inventory_closed()
	else:
		_on_inventory_opened()


func _on_kc_list_focus_entered() -> void:
	$Keychain/KcList.select(0)
	pass # Replace with function body.


func _on_kc_list_focus_exited() -> void:
	$Keychain/KcList.deselect_all()
	pass # Replace with function body.
