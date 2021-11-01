extends Node

var all_item_data : Array = []

#[{head:1}, {chest:2}, {hands:3}, {legs:4}, {feet:5}, {main_hand:6}, {off_hand:7}, {ring:8}, {amulet:9}, {not_an_item:0}]
var item_categories : Array = []

var equip_slots : Array = []

func GetItemID(file_name):
	for item in all_item_data:
		if item["file_name"] == file_name:
			return int(item["item_id"])
			
func GetItemCategory(file_name):
	for item in all_item_data:
		if item["file_name"] == file_name:
			return int(item["item_category_id"])

func CreateItemCategoriesList(item_categories_data):
	for category in item_categories_data:
		item_categories.append({category["item_category"] : int(category["item_category_id"])})

func CreateEquipSlots(equip_slots_data):
	for equip in equip_slots_data:
		equip_slots.append({int(equip["equip_slot"]) : int(equip["item_category"])})

		
