extends Node2D
class_name NpcBaseClass

export var npc_name : String
var npc_quests_starts : Dictionary = {}
var npc_quests_ends : Dictionary = {}

# TODO make this open dialog instead of just emitting signal
signal change_quest_state(player_quest_state) #this is just a testing function for now
signal quest_completed()

# If the npc is involved in the quest they will have that quest added to the dictionary.
func set_npc_quests(all_quests : Dictionary):
	# TODO unfinished
	if all_quests.hash() == {}.hash():
		# should fail something here
		Logger.warn("No Quest database on client")
		return
	for quest_id in all_quests:
		if all_quests[quest_id]["npc_starts"] == npc_name:
			npc_quests_starts[quest_id] = all_quests[quest_id]
		if all_quests[quest_id]["npc_ends"] == npc_name:
			npc_quests_ends[quest_id] = all_quests[quest_id]

func get_npc_quests() -> Dictionary:
	var npc_quests : Dictionary = {
		"npc_quests_starts" : npc_quests_starts,
		"npc_quests_ends" : npc_quests_ends
	}
	return npc_quests

# shows or hides the exclamation mark / Finished quest symbol if we have one
func check_if_player_quests_changed(player_quests):
	pass


func _on_TouchScreenButton_pressed() -> void:
	pass # Replace with function body.

# TODO
func _on_NPCInteract_pressed() -> void:
	# Testing function REMOVE LATER
	var TEST_completed : String = str(randi() % 50)
	var TEST_new_quest_state : Dictionary = {
		"player_started_quests": {
			"3": {
				"kill_enemies": {
					"slimes": randi() % 50,
					"minos" : randi() % 50
				}
			}
		},
		"all_quest_ids_completed": {
			TEST_completed: null
		}
	}
	# TODO make this not gross
	var player = get_parent().get_parent().get_node("Player")
	
	
	
	emit_signal("change_quest_state", TEST_new_quest_state)
