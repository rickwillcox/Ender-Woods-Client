extends Node

# This is the script that updates deals with all the NPC logic and gets everything ready to connect with dialogic.

# passing in the node so I can unit test
func set_npc_quests_start_end(NpcYsortNode : YSort, all_quests : Dictionary) -> void: 
	for npc in NpcYsortNode.get_children():
		npc.set_npc_quests(all_quests)


func update_npc_quests_based_on_player_quest_state(player_stats : Dictionary, player : KinematicBody2D):
	if player: 
		#quests the player can start
		var available_quest_ids_to_start : Dictionary = player.player_quests.check_all_quest_requirements_to_start(player.player_stats, AllQuests.all_quests)
		print("available_quest_ids_to_start: ", available_quest_ids_to_start)
	else:
		assert(false, "Player not found")
		
