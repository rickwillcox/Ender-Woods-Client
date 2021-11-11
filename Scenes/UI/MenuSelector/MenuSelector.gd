extends VBoxContainer


export var current_menu : int = 0
onready var menu_buttons = [$InventoryBtn, $StatusBtn]

func _ready():
	init_menu_buttons_pressed()

func init_menu_buttons_pressed():
	var index = 0
	for btn in menu_buttons:
		if index == current_menu:
			btn.pressed = true
		else:
			btn.pressed = false
		index += 1

func _on_InventoryBtn_toggled(button_pressed):
	if current_menu == 0:
		menu_buttons[current_menu].pressed = true
	else:
		open_Inventory()

func _on_StatusBtn_toggled(button_pressed):
	if current_menu == 1:
		menu_buttons[current_menu].pressed = true
	else:
		open_Status()

func open_Inventory():
	pass

func open_Status():
	pass
