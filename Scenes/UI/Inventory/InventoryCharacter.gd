extends Node2D

var equip_slots : Dictionary = {
	26: "Head",
	27: "Chest",
	31: "Gloves",
	29: "MainHand",
	30: "Offhand",
	34: "Pants",
	35: "Boots"
}
onready var nude_head = preload("res://Assets/Player/Nude/head_nude.png")
onready var nude_chest = preload("res://Assets/Player/Nude/chest_nude.png")
onready var nude_hands = preload("res://Assets/Player/Nude/hands_nude.png")
onready var nude_main_hand =  preload("res://Assets/Player/Weapon Sprites/sword.png")
onready var nude_offhand = [null,preload("res://Assets/Player/Weapon Sprites/axe.png")]
onready var nude_legs = preload("res://Assets/Player/Nude/pants_nude.png")
onready var nude_boots = preload("res://Assets/Player/Nude/feet_nude.png")

onready var silver_head = preload("res://Assets/Player/Silver Armour/head_silver_armour.png")
onready var silver_chest = preload("res://Assets/Player/Silver Armour/chest_silver_armour.png")
onready var silver_hands = preload("res://Assets/Player/Silver Armour/hands_silver_armour.png")
onready var silver_legs = preload("res://Assets/Player/Silver Armour/pants_silver_armour.png")
onready var silver_boots = preload("res://Assets/Player/Silver Armour/feet_silver_armour.png")
onready var silver_main_hand =  preload("res://Assets/Player/Weapon Sprites/sword.png")
onready var silver_off_hand = preload("res://Assets/Player/Weapon Sprites/wood_cutting_axe.png")

#nude 0, silver 1


func ChangeCharacterEquips(item_slot):  
	if int(item_slot) in equip_slots:
		var equip_type = equip_slots[item_slot]
		get_node(equip_type).texture = chest[1]

