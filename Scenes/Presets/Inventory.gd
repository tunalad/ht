extends Control

@export var pocket_items : Array[InventoryItem]
@export var backpack_items : Array[InventoryItem]
@export var keychain_items : Array[InventoryItem]

var inventory_dict : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DevConsole.connect("on_terminal_closed", _on_dev_console_console_closed)
	DevConsole.connect("inventory_do", _on_inventory_do)
	DevConsole.connect("backpack_do", _on_backpack_do)
	DevConsole.connect("give_item", add_to_inventory)
	
	$".".visible = false
	
	populate_pockets()
	populate_backpack()
	populate_keychain()
	$GridPocket/PocketPos1.grab_focus()


func _input(event: InputEvent) -> void:
	if $".".visible and event is InputEventKey and event.is_released():
		# description handling
		if get_focused_node_name() == "KcList":
			var selected_item_id : int = $Keychain/KcList.get_selected_items()[0]
			var selected_item : InventoryItem = keychain_items[selected_item_id]
			$DescBox/MarginContainer/VBoxContainer/Label.text = selected_item.title + " - "  + selected_item.description
		elif inventory_dict.has(get_focused_node_name()):
			var now_focused : Dictionary = inventory_dict[get_focused_node_name()]
			if now_focused:
				$DescBox/MarginContainer/VBoxContainer/Label.text = now_focused.title + " - "  + now_focused.description
		else:
			$DescBox/MarginContainer/VBoxContainer/Label.text = ""


func populate_pockets() -> void:
	for item in pocket_items.size():
		if pocket_items[item]:
			var grid_item_name : String = "PocketPos%d" % (item + 1)
			var grid_item := $GridPocket.get_node(grid_item_name)
			
			if !pocket_items[item].icon:
				grid_item.text = pocket_items[item].title
			else:
				grid_item.icon = pocket_items[item].icon
			
			inventory_dict[grid_item_name] = {
				"title": pocket_items[item].title,
				"description": pocket_items[item].description
			}


func populate_backpack() -> void:
	for item in backpack_items.size():
		if backpack_items[item]:
			print("add `", backpack_items[item].title, "` to the backpack")
			var grid_item_name : String = "BpPos%d" % (item + 1)
			var grid_item := $GridBackpack.get_node(grid_item_name)
			if !backpack_items[item].icon:
				grid_item.text = backpack_items[item].title
			else:
				grid_item.icon = backpack_items[item].icon
			#grid_item.text = str(item)
			inventory_dict[grid_item_name] = {
				"title": backpack_items[item].title,
				"description": backpack_items[item].description
			}


func populate_keychain() -> void:
	for item in keychain_items.size():
		if keychain_items[item]:
			print(item, ": add `", keychain_items[item].title, "` to the keychain")
			$Keychain/KcList.add_item(keychain_items[item].title)
			inventory_dict["Key"+str(item)] = {
				"title": keychain_items[item].title,
				"description": keychain_items[item].description
			}


func get_focused_node_name() -> String:
	var focused_control := get_viewport().gui_get_focus_owner()
	if focused_control:
		return focused_control.name
	return ""


func keychain_position() -> void:
	if $GridBackpack.visible:
		$Keychain.set_position(Vector2(64, 256))
	else:
		$Keychain.set_position(Vector2(424, 96))


func add_to_inventory(item : Defs.InvItem, item_kind: Defs.InvKind = Defs.InvKind.BACKPACK, notify: bool = false) -> void:
	var resource : Resource = get_resource(item)
	
	match item_kind:
		Defs.InvKind.BACKPACK:
			backpack_items.append(resource)
			populate_backpack()
			#print("added %s to backpack" % resource.title)
		Defs.InvKind.POCKET:
			pocket_items.append(resource)
			populate_pockets()
			#print("added %s to pocket" % resource.title)
		Defs.InvKind.KEY:
			keychain_items.append(resource)
			populate_keychain()
			#print("added %s to keychain" % resource.title)
	if notify:
		print("item added to inventory")
		DevConsole.notify("Helen found:\n\"%s\"" % resource.title)


func get_resource(type: Defs.InvItem) -> Resource:
	match type:
		Defs.InvItem.MUSIC_PLAYER:
			return preload("res://Resources/InvMusicplayer.tres")
		Defs.InvItem.RECORDER:
			return preload("res://Resources/InvRecorder.tres")
		Defs.InvItem.TAPE:
			return preload("res://Resources/InvTape.tres")
		Defs.InvItem.TAPE_CASED:
			return preload("res://Resources/InvTapeCased.tres")
		Defs.InvItem.KEY_BAKERY:
			return preload("res://Resources/KeyBakery.tres")
		Defs.InvItem.KEY_HOME:
			return preload("res://Resources/KeyHome.tres")
		_:
			return null


func _on_dev_console_console_closed() -> void:
	$GridPocket/PocketPos1.grab_focus()
	pass


func _on_inventory_do(action : String) -> void:
	if action == "close":
		$".".visible = false
	elif action == "open":
		$".".visible = true
		DevConsole.console("close")
	elif action == "toggle":
		if $".".visible:
			$".".visible = false
		else:
			$".".visible = true
			DevConsole.console("close")


func _on_backpack_do(action : String) -> void:
	if action == "show":
		$GridBackpack.visible = true
	elif action == "hide":
		$GridBackpack.visible = false
	elif action == "toggle":
		$GridBackpack.visible = !$GridBackpack.visible
	keychain_position()


func _on_kc_list_focus_entered() -> void:
	$Keychain/KcList.select(0)
	pass # Replace with function body.


func _on_kc_list_focus_exited() -> void:
	$Keychain/KcList.deselect_all()
	pass # Replace with function body.
