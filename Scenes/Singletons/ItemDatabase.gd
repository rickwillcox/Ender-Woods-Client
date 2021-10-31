extends Node

var all_item_data

func GetItemID(file_name):
	for item in all_item_data:
		if item["file_name"] == file_name:
			return item["item_id"]
			
func GetItemCategory(file_name):
	for item in all_item_data:
		if item["file_name"] == file_name:
			return item["item_category"]

