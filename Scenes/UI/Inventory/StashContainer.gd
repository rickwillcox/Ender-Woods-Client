tool
extends GridContainer
var start_item_slot = ItemDatabase.Slots.FIRST_STASH_SLOT

func add_child(node: Node, legible_unique_name: bool = false):
	.add_child(node, legible_unique_name)
	var i = start_item_slot
	for child in get_children():
		child.item_slot = i
		i += 1
