extends Node2D

var npc_name : String
var npc_quests :Dictionary = {}

# If the npc is involved in the quest they will have that quest added to the dictionary.
func set_npc_quests(quests : Dictionary):
	for quest_id in quests:
		if quest_id["npc_begins"] == npc_name or quest_id["npc_ends"] == npc_name:
			npc_quests[quest_id] = quests[quest_id]

func get_npc_quests():
	return npc_quests

# shows or hides the exclamation mark / Finished quest symbol if we have one
func check_if_player_quests_changed(player_quests):
	
