tool
extends GridContainer

export(bool) var update_item_slots setget update_item_slots

var slots = [
	ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT,
	ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT + 1,
	ItemDatabase.Slots.FIRST_SMELTING_INPUT_SLOT + 2,
	ItemDatabase.Slots.COAL_SMELTING_INPUT_SLOT,
	ItemDatabase.Slots.FIRST_SMELTING_OUTPUT_SLOT,
	ItemDatabase.Slots.FIRST_SMELTING_OUTPUT_SLOT + 1,
	ItemDatabase.Slots.FIRST_SMELTING_OUTPUT_SLOT + 2
]

func update_item_slots(_x):
	var i = 0
	for child in get_children():
		if child is ItemSlot:
			(child as ItemSlot).item_slot = slots[i]
			i += 1
