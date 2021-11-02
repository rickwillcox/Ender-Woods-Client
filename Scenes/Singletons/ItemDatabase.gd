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
