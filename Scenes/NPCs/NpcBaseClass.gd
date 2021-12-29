extends Node2D
class_name NpcBaseClass

export var npc_name : String
var npc_quests_starts : Dictionary = {}
var npc_quests_ends : Dictionary = {}
var player_quests_instance : PlayerQuests = PlayerQuests.new()

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

func get_quests_player_can_start(player_stats : Dictionary, player_quests : Dictionary, all_quests : Dictionary):
	return player_quests_instance.check_all_quest_requirements_to_start(player_stats, player_quests, all_quests)
	
func get_quests_player_has_started(player_quests : Dictionary):
	return player_quests_instance.get_player_started_quests(player_quests)

func get_quests_player_has_completed(player_quests : Dictionary):
	return player_quests_instance.get_player_completed_quests(player_quests)

func player_npc_quest_state(player_stats : Dictionary, player_quests : Dictionary, all_quests : Dictionary) -> Dictionary:
	var quests_player_can_start = get_quests_player_can_start(player_stats, player_quests, all_quests)
	var quests_player_has_started = get_quests_player_has_started(player_quests)	
	var quests_player_has_completed = get_quests_player_has_completed(player_quests)
	
	# TODO quests_ready_to_be_completed (milestones reached)
	# npc_quest_state is specific to each npc, this will give us the varaibles needed to use in Dialogic
	var npc_quest_state : Dictionary = {
		"quests_to_start" : {},
		"quests_already_started" : {},
		"quests_ready_to_be_completed" : {},
		"quests_completed" : {}
	}
	
	for quest in quests_player_can_start:
		if quest in npc_quests_starts:
			npc_quest_state["quests_to_start"][quest] = null
	
	for quest in quests_player_has_started:
		if quest in npc_quests_starts:
			npc_quest_state["quests_already_started"][quest] = null
	
	# This is for when player has finished the quest but not turned it in
	for quest in quests_player_has_started:
		#check tasks here
		check_all_tasks_completed
		if quest in npc_quests_starts and all_tasks_completed:
			npc_quest_state["quests_ready_to_be_completed"][quest] = null
	
		
	
	return npc_quest_state
	
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
