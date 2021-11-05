extends Node

var all_item_data : Dictionary

# Item categories
enum {NOT_EQUIPPABLE = 0, HEAD, CHEST, HANDS, LEGS, FEET, MAIN_HAND, OFF_HAND, RING, AMULET}
enum Slots {HEAD_SLOT = 0, CHEST_SLOT, HANDS_SLOT, LEGS_SLOT, FEET_SLOT, MAIN_HAND_SLOT, OFF_HAND_SLOT, RING_SLOT_1, RING_SLOT_2, AMULET_SLOT, MAX_EQUIP_SLOTS}
var item_category_to_slot_mapping = \
		{NOT_EQUIPPABLE: [],
		HEAD: [Slots.HEAD_SLOT],
		CHEST: [Slots.CHEST_SLOT],
		HANDS: [Slots.HANDS_SLOT],
		LEGS: [Slots.LEGS_SLOT],
		FEET: [Slots.FEET_SLOT],
		MAIN_HAND: [Slots.MAIN_HAND_SLOT],
		OFF_HAND: [Slots.OFF_HAND_SLOT],
		RING: [Slots.RING_SLOT_1, Slots.RING_SLOT_2],
		AMULET: [Slots.AMULET_SLOT]}

func item_fits_slot(item_category : int, slot : int) -> bool:
	if slot >= Slots.MAX_EQUIP_SLOTS:
		return true
	return slot in item_category_to_slot_mapping[item_category]

func item_category(item_id : int):
	if item_id == -1:
		return null
	return int(all_item_data[item_id]["item_category"])

func swap_items(from : int, to : int, inventory : Dictionary):
	if not from in inventory.keys():
		# nothing to do, from needs to be an item
		return
	if not to in inventory.keys():
		# only source item exists, just change its slot
		inventory[to] = inventory[from]
		# this slot is no longer occupied, erase it from dictionary
		inventory.erase(from)
		return
	
	# both items exist, swap them
	var item = inventory[to]
	inventory[to] = inventory[from]
	inventory[from] = item

func move_items(from : int, to : int, inventory : Dictionary) -> bool:
	if not from in inventory.keys():
		# nothing to do, from needs to be an item
		return false
	if not to in inventory.keys():
		# only source item exists, just change its slot
		inventory[to] = inventory[from]
		# this slot is no longer occupied, erase it from dictionary
		inventory.erase(from)
		return true
	
	# Case 1: Item id mismatch, just swap them
	if inventory[from]["item_id"] != inventory[to]["item_id"]:
		swap_items(from, to, inventory)
		return true
	
	# Case 2: Items have the same IDs
	var item_id = inventory[from]["item_id"]
	var stack_size = int(ItemDatabase.all_item_data[item_id]["stack_size"])
	# Case 2a: target slot is already full, cannot move
	if stack_size <= inventory[to]["amount"]:
		return false
		
	# Case 2b: There is some space left on the stack
	var total_items = inventory[from]["amount"] + inventory[to]["amount"]
	inventory[to]["amount"] = min(stack_size, total_items)
	var leftover = total_items - stack_size
	if leftover <= 0:
		# All items fit into one slot, stack them, free from slot
		inventory.erase(from)
	else:
		# Some items didn't fit. Keep the from slot occupied, modify number of items
		inventory[from]["amount"] = leftover
		
	return true

func is_move_to_slot_allowed(from : int, to : int, inventory : Dictionary):
	# error, item from  doesnt exist
	if not inventory.has(from):
		return false
	
	# to empty slot
	if not inventory.has(to):
		return item_fits_slot(item_category(inventory[from]["item_id"]), to)
		
	return item_fits_slot(item_category(inventory[from]["item_id"]), to) and \
		item_fits_slot(item_category(inventory[to]["item_id"]), from)
