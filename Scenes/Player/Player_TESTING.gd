extends KinematicBody2D

# Currently only using this for quest testing. Add in more if needed

var player_id : int
var max_hp : int = 30
var current_hp : int = 30

var player_quests : PlayerQuests = PlayerQuests.new()

var player_stats : Dictionary = {
		"level" : 0
	}

		
func set_quests(updated_quests):
	#this checks if the quest state is the same or we get an infinite loop of death
	if not updated_quests.hash() == player_quests.get_player_quests().hash():
		player_quests.set_player_quests(player_quests.get_player_quests(), updated_quests)
		# Make NPCs change their state if needed based on the new quest state
		NpcLogic.update_npc_quests_based_on_player_quest_state(player_stats, self)
	
func get_quests():
	return player_quests.get_player_quests()
