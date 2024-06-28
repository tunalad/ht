extends Control

var items_count = 2 # count of options in menu
var current_menu = MENU.MAIN # menu we're on atm
var selected_item = 1 # position of our cursor


enum MENU { MAIN, SELECT }

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if current_menu == MENU.MAIN:
			current_menu = MENU.SELECT
			change_menu(MENU.SELECT)
		elif current_menu == MENU.SELECT:
			current_menu = MENU.MAIN
			change_menu(MENU.MAIN)
	
	handle_selected_item()

func split_title_menu():
	# this gets the size of the sceen
	# then splits it into two 
	# one for the title, other for the menu
	var total_height = get_viewport_rect().size.y
	var half_height = total_height / 2
	
	$"Title Container".custom_minimum_size.y = half_height
	$menu_main.custom_minimum_size.y = half_height

func change_menu(change_menu):
	if change_menu == MENU.MAIN:
		$menu_main/menu_select.hide()
		$menu_main/menu_main.show()
	if change_menu == MENU.SELECT:
		$menu_main/menu_select.show()
		$menu_main/menu_main.hide()
	pass

func handle_selected_item():
	if Input.is_action_just_pressed("ui_down"):
		selected_item += 1
	elif Input.is_action_just_pressed("ui_up"):
		selected_item -= 1
	
	if selected_item > items_count or selected_item < 1:
			selected_item = 1
	
	# highlight the item by setting it's color to red (default is white)
	# so we take the child of the menu we're on, and color it red
