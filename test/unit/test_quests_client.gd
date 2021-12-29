extends "res://addons/gut/test.gd"

# notes 
# give player empty_player_quest_state initially in real game (maybe)

# all_quests will need to be updated as we add new quests, just copy the exact json from the nakama storage object.
var all_quests : Dictionary = {
  "1": {
	"story": "Player wakes up naked on the beach, after being washed ashore. Fisherman Bob nearby offers you some help and tells you to talk to his village chief and also give him this bucket of fish as he might be able to provide you further assistance. When you talk to Beach Chief Sam he sees you are hurt and offers you some Health Potions to heal. He also takes the fish.",
	"npc_ends": "beach_chief_sam",
	"milestones": {},
	"npc_starts": "fisherman_bob",
	"quest_name": "I hate wet feet",
	"item_rewards": {
	  "REPLACE_minor_health_potion_ITEM_ID": {
		"quantity": 3,
		"item_name": "Minor Potion of Health"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {}
	},
	"other_rewards": {},
	"items_given_at_beginning_of_quest": {
	  "REPLACE_bucket_of_fish_ITEM_ID": {
		"quantity": 1,
		"item_name": "Bucket of Fish"
	  }
	},
	"items_taken_from_player_on_completion": {
	  "REPLACE_bucket_of_fish_ITEM_ID": {
		"quantity": 1,
		"item_name": "Bucket of Fish"
	  }
	}
  },
  "2": {
	"story": "Player talks to Beach Chief Sam, Sam says all are welcome here as long as they put in their fair share of work.He tells you how he is craving some beautiful crab soup but the hunters have gone missing for weeks now and there is no one here to hunt the crabs anymore. How about you take this copper sword and go get the crab guts for me and I will return the favour by giving you some coin to get you started on your travels.",
	"npc_ends": "beach_chief_sam",
	"milestones": {},
	"npc_starts": "beach_chief_sam",
	"quest_name": "Crab soup",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 10,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"1": null
	  }
	},
	"other_rewards": {
	  "player_experience": 100
	},
	"items_given_at_beginning_of_quest": {
	  "6": {
		"quantity": 1,
		"item_name": "Copper Sword"
	  }
	},
	"items_taken_from_player_on_completion": {
	  "REPLACE_CRAB_GUTS_ITEM_ID": {
		"quantity": 10,
		"item_name": "Crab Guts"
	  }
	}
  },
  "3": {
	"story": "Player gets told to go look for those damn miners. They haven't been back in days, things are not like they used to be around here. Player then follows the beach track over to the Miners who have a camp set up.",
	"npc_ends": "miner_greg",
	"milestones": {},
	"npc_starts": "beach_chief_sam",
	"quest_name": "Where are those damn miners?",
	"item_rewards": {},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"2": null
	  }
	},
	"other_rewards": {
	  "player_experience": 100
	},
	"items_given_at_beginning_of_quest": {
	  "REPLACE_NOTE_FOR_MINER_GREG": {
		"quantity": 1,
		"item_name": "Note for Miner Greg"
	  }
	},
	"items_taken_from_player_on_completion": {
	  "REPLACE_NOTE_FOR_MINER_GREG": {
		"quantity": 1,
		"item_name": "Note for Miner Greg"
	  }
	}
  },
  "4": {
	"story": "Miner Greg after having read the note from Beach Chief Sam whines about how he has no idea how things work these days, “we've only been gone for a few days, cant the old bastard look after himself for a few days?”. Anyways kid, since you’re new here you are going to need some gear. I tell you what, Ill give you this copper pickaxe if you'll go get me 10 copper ore from those rocks over there. If you can do that ill give you a nice pair of boots that’ll protect ya feet from the hot sand. ",
	"npc_ends": "miner_greg",
	"milestones": {},
	"npc_starts": "miner_greg",
	"quest_name": "Go hit some rocks kid!",
	"item_rewards": {
	  "5": {
		"quantity": 1,
		"item_name": "Copper Boots"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"1": null,
		"2": null,
		"3": null
	  }
	},
	"other_rewards": {
	  "mining_experience": 100
	},
	"items_given_at_beginning_of_quest": {
	  "10": {
		"quantity": 1,
		"item_name": "Copper Pickaxe"
	  }
	},
	"items_taken_from_player_on_completion": {
	  "100000": {
		"quantity": 10,
		"item_name": "Copper Ore"
	  }
	}
  },
  "5": {
	"story": "Miner Greg tells you that unless you want to end up like the cranky old man (referring to Beach Chief Sam), I'd get the hell off the beach whilst you can. He says he doesn't know much about the rest of the world but his friend Travelling Vendor Robby hangs out around the crossroads selling  various goods and that you should ask him where to go next. Or do whatever you want, what do I care? The player then upon leaving the beach sees an obvious crossroads ahead where he finds Travelling Vendor Robby. Robby then offers you some items from his shop, but you can only afford to buy 1 small cooked fish. Robby scoffs at your poverty and tosses a single silver coin at your feet in disgust. ",
	"npc_ends": "travelling_vendor_robby",
	"milestones": {},
	"npc_starts": "miner_greg",
	"quest_name": "These boots were made for walkin",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 1,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"1": null,
		"2": null,
		"3": null,
		"4": null
	  }
	},
	"other_rewards": {
	  "player_experience": 100
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {}
  },
  "6": {
	"story": "Why are you even hanging around me? Be gone. Bloody peasants wasting my time, you bloody young people and your work ethic, go get yourself a job from the Recruiter Billy in town and get your act together! Player … Player then goes to town and finds Recruiter Billy standing next to the Job Board, Billy tells you there is always work to be done and you can always find work on this Job Board. Player What do you do then? Billy: ...",
	"npc_ends": "recruiter_billy",
	"milestones": {},
	"npc_starts": "travelling_vendor_robby",
	"quest_name": "Time to make something of myself…. I guess",
	"item_rewards": {},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"1": null,
		"2": null,
		"3": null,
		"4": null,
		"5": null
	  }
	},
	"other_rewards": {
	  "player_experience": 100
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {}
  },
  "7": {
	"story": "First Job Board quest and last in the first quest chain. Introduces the player to the job board. Kill 15 deer.",
	"npc_ends": "ender_town_job_board",
	"milestones": {
	  "enemies_left_to_kill": {
		"deer": 15
	  }
	},
	"npc_starts": "ender_town_job_board",
	"quest_name": "Deers gotta go",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 5,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": false,
	  "previous_quests_completed": {
		"1": null,
		"2": null,
		"3": null,
		"4": null,
		"5": null,
		"6": null
	  }
	},
	"other_rewards": {
	  "player_experience": 200
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {}
  },
  "1001": {
	"story": "Job Board repeatable quest: Kill 15 boars",
	"npc_ends": "ender_town_job_board",
	"milestones": {
	  "enemies_left_to_kill": {
		"boar": 15
	  }
	},
	"npc_starts": "ender_town_job_board",
	"quest_name": "Hunt some Boars",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 5,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": true,
	  "previous_quests_completed": {
		"7": null
	  }
	},
	"other_rewards": {
	  "player_experience": 200
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {}
  },
  "1002": {
	"story": "Job Board repeatable quest: Kill 20 slimes",
	"npc_ends": "ender_town_job_board",
	"milestones": {
	  "enemies_left_to_kill": {
		"slime": 20
	  }
	},
	"npc_starts": "ender_town_job_board",
	"quest_name": "Squishy Slimes",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 10,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": true,
	  "previous_quests_completed": {
		"7": null
	  }
	},
	"other_rewards": {
	  "player_experience": 200
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {}
  },
  "1003": {
	"story": "Job Board repeatable quest: Trade in 20 Boar Meat",
	"npc_ends": "ender_town_job_board",
	"milestones": {},
	"npc_starts": "ender_town_job_board",
	"quest_name": "Pig on a spit",
	"item_rewards": {
	  "REPLACE_SILVER_COINS_ITEM_ID": {
		"quantity": 40,
		"item_name": "Silver Coin"
	  }
	},
	"requirements": {
	  "max_level": 0,
	  "min_level": 0,
	  "repeatable": true,
	  "previous_quests_completed": {
		"7": null
	  }
	},
	"other_rewards": {
	  "player_experience": 800
	},
	"items_given_at_beginning_of_quest": {},
	"items_taken_from_player_on_completion": {
	  "REPLACE_BOAR_MEAT_ITEM_ID": {
		"quantity": 20,
		"item_name": "Boar Meat"
	  }
	}
  }
}
var empty_player_quest_state : Dictionary = {
		"player_started_quests": {},
		"player_completed_quest_ids": {}
	}

# all npcs stored under this node
var NpcYsortNode

# player node to reference in tests
var player 

# npc nodes that you can reference in tests
var fisherman_bob
var beach_chief_sam
var miner_greg
var travelling_vendor_robby
var recruiter_billy
var ender_town_job_board

# all npc scenes (only used to load)
var npc_fisherman_bob_scene
var npc_beach_chief_sam_scene
var npc_miner_greg_scene
var npc_travelling_vendor_robby_scene
var npc_recruiter_billy_scene
var npc_ender_town_job_board_scene

func before_all():
	name = "QuestTestScene"
	# set up the NPCs same conditions as in the real game
	setup_npcs()
	# Makes sure all the npcs are assigned their quests correctly based on the all_quests json from nakama (defined as all_quests in this script)	
	# THESE TESTS WILL BREAK IF YOU CHANGE all_quests!
	check_setup_fisherman_bob()
	check_setup_beach_chief_sam()
	check_setup_miner_greg()
	check_setup_travelling_vendor_robby()
	check_setup_recruiter_billy()
	check_setup_ender_town_job_board()

func before_each():
	setup_player()
	check_setup_player()
	assert_true(self.has_node("Player"))
	
func after_each():
	player.free()
	assert_false(self.has_node("Player"))
	
func test_set_get_player_quests():
	var player_quest_state : Dictionary = {
		"player_started_quests": {
			"4": {}
		},
		"player_completed_quest_ids": {
			"1" : null,
			"2" : null,
			"3": null
		}
	}
	player.player_quests.set_player_quests(player.player_quests.get_player_quests(), player_quest_state)
	#Check quests were updated
	assert_eq_deep(player.player_quests.get_player_quests(), player_quest_state)
	
func test_fisherman_bob_player_quests():
	var player_stats : Dictionary = {
		"level" : 0
	}

	
	
	
	
	
	




# Set Up Functions used in before_all()

func setup_npcs():
	npc_fisherman_bob_scene = load("res://Scenes/NPCs/FishermanBob.tscn")
	npc_beach_chief_sam_scene = load("res://Scenes/NPCs/BeachChiefSam.tscn")
	npc_miner_greg_scene = load("res://Scenes/NPCs/MinerGreg.tscn")
	npc_travelling_vendor_robby_scene = load("res://Scenes/NPCs/TravellingVendorRobby.tscn")
	npc_recruiter_billy_scene = load("res://Scenes/NPCs/RecruiterBilly.tscn")
	npc_ender_town_job_board_scene = load("res://Scenes/NPCs/EnderTownJobBoard.tscn")
	
	var npc_fisherman_bob = npc_fisherman_bob_scene.instance()
	var npc_beach_chief_sam = npc_beach_chief_sam_scene.instance()
	var npc_miner_greg = npc_miner_greg_scene.instance()
	var npc_travelling_vendor_robby = npc_travelling_vendor_robby_scene.instance()
	var npc_recruiter_billy = npc_recruiter_billy_scene.instance()
	var npc_ender_town_job_board = npc_ender_town_job_board_scene.instance()
	
	NpcYsortNode = YSort.new()
	NpcYsortNode.name = "NpcYsortNode"
	add_child(NpcYsortNode)
	
	NpcYsortNode.add_child(npc_fisherman_bob)
	NpcYsortNode.add_child(npc_beach_chief_sam)
	NpcYsortNode.add_child(npc_miner_greg)
	NpcYsortNode.add_child(npc_travelling_vendor_robby)
	NpcYsortNode.add_child(npc_recruiter_billy)
	NpcYsortNode.add_child(npc_ender_town_job_board)
	
	fisherman_bob = get_node("NpcYsortNode/FishermanBob")
	beach_chief_sam = get_node("NpcYsortNode/BeachChiefSam")
	miner_greg = get_node("NpcYsortNode/MinerGreg")
	travelling_vendor_robby = get_node("NpcYsortNode/TravellingVendorRobby")
	recruiter_billy = get_node("NpcYsortNode/RecruiterBilly")
	ender_town_job_board = get_node("NpcYsortNode/EnderTownJobBoard")
	
	#sets quests for ALL npcs
	NpcLogic.set_npc_quests_start_end(NpcYsortNode, all_quests)

func check_setup_fisherman_bob():
	assert_true(NpcYsortNode.has_node("FishermanBob"))
	assert_has_method(fisherman_bob, "get_npc_quests")
	assert_has_method(fisherman_bob, "set_npc_quests")
	assert_has_method(fisherman_bob, "_on_NPCInteract_pressed")
	assert_true("npc_name" in fisherman_bob)
	assert_true("npc_quests_starts" in fisherman_bob)
	assert_true("npc_quests_ends" in fisherman_bob)
	assert_true("npc_quests_starts" in fisherman_bob.get_npc_quests())
	assert_true("npc_quests_ends" in fisherman_bob.get_npc_quests())
	
	# Fisherman Bob | starts : 1 | ends : none
	# starting quest tests
	assert_true(fisherman_bob.npc_quests_starts.size() == 1)
	assert_false(fisherman_bob.npc_quests_starts.size() == 2)
	assert_true("1" in fisherman_bob.npc_quests_starts)
	assert_false("2" in fisherman_bob.npc_quests_starts)
	# ending quests tests
	assert_true(fisherman_bob.npc_quests_ends.size() == 0)
	assert_false(fisherman_bob.npc_quests_ends.size() == 1)
	
func check_setup_beach_chief_sam():
	assert_true(NpcYsortNode.has_node("BeachChiefSam"))
	assert_has_method(beach_chief_sam, "get_npc_quests")
	assert_has_method(beach_chief_sam, "set_npc_quests")
	assert_has_method(beach_chief_sam, "_on_NPCInteract_pressed")
	assert_true("npc_name" in beach_chief_sam)
	assert_true("npc_quests_starts" in beach_chief_sam)
	assert_true("npc_quests_ends" in beach_chief_sam)
	assert_true("npc_quests_starts" in beach_chief_sam.get_npc_quests())
	assert_true("npc_quests_ends" in beach_chief_sam.get_npc_quests())
	
	# Beach Chief Sam | starts : 2, 3 | ends : 1 , 2
	# starting tests
	assert_true(beach_chief_sam.npc_quests_starts.size() == 2)
	assert_false(beach_chief_sam.npc_quests_starts.size() == 3)
	assert_true("2" in beach_chief_sam.npc_quests_starts)
	assert_true("3" in beach_chief_sam.npc_quests_starts)
	assert_false("1" in beach_chief_sam.npc_quests_starts)
	assert_false("4" in beach_chief_sam.npc_quests_starts)
	# ending tests
	assert_true(beach_chief_sam.npc_quests_ends.size() == 2)
	assert_false(beach_chief_sam.npc_quests_ends.size() == 3)
	assert_true("1" in beach_chief_sam.npc_quests_ends)
	assert_true("2" in beach_chief_sam.npc_quests_ends)
	assert_false("3" in beach_chief_sam.npc_quests_ends)
	assert_false("4" in beach_chief_sam.npc_quests_ends)
	
func check_setup_miner_greg():
	assert_true(NpcYsortNode.has_node("MinerGreg"))
	assert_has_method(miner_greg, "get_npc_quests")
	assert_has_method(miner_greg, "set_npc_quests")
	assert_has_method(miner_greg, "_on_NPCInteract_pressed")
	assert_true("npc_name" in miner_greg)
	assert_true("npc_quests_starts" in miner_greg)
	assert_true("npc_quests_ends" in miner_greg)
	assert_true("npc_quests_starts" in miner_greg.get_npc_quests())
	assert_true("npc_quests_ends" in miner_greg.get_npc_quests())
	
	# Miner Greg | starts : 4, 5 | ends : 3, 4
	# starting tests
	assert_true(miner_greg.npc_quests_starts.size() == 2)
	assert_false(miner_greg.npc_quests_starts.size() == 1)
	assert_false(miner_greg.npc_quests_starts.size() == 3)
	assert_true("4" in miner_greg.npc_quests_starts)
	assert_true("4" in miner_greg.npc_quests_starts)
	assert_false("3" in miner_greg.npc_quests_starts)
	assert_false("6" in miner_greg.npc_quests_starts)
	# ending tests
	assert_true(miner_greg.npc_quests_ends.size() == 2)
	assert_false(miner_greg.npc_quests_ends.size() == 1)
	assert_false(miner_greg.npc_quests_ends.size() == 3)
	assert_true("3" in miner_greg.npc_quests_ends)
	assert_true("4" in miner_greg.npc_quests_ends)
	assert_false("2" in miner_greg.npc_quests_ends)
	assert_false("5" in miner_greg.npc_quests_ends)
	
func check_setup_travelling_vendor_robby():
	assert_true(NpcYsortNode.has_node("TravellingVendorRobby"))
	assert_has_method(travelling_vendor_robby, "get_npc_quests")
	assert_has_method(travelling_vendor_robby, "set_npc_quests")
	assert_has_method(travelling_vendor_robby, "_on_NPCInteract_pressed")
	assert_true("npc_name" in travelling_vendor_robby)
	assert_true("npc_quests_starts" in travelling_vendor_robby)
	assert_true("npc_quests_ends" in travelling_vendor_robby)
	assert_true("npc_quests_starts" in travelling_vendor_robby.get_npc_quests())
	assert_true("npc_quests_ends" in travelling_vendor_robby.get_npc_quests())
	
	# Travelling Vendor Robby | starts : 6 | ends : 5
	# starting tests
	assert_true(travelling_vendor_robby.npc_quests_starts.size() == 1)
	assert_false(travelling_vendor_robby.npc_quests_starts.size() == 0)
	assert_false(travelling_vendor_robby.npc_quests_starts.size() == 2)
	assert_true("6" in travelling_vendor_robby.npc_quests_starts)
	assert_false("4" in travelling_vendor_robby.npc_quests_starts)
	assert_false("5" in travelling_vendor_robby.npc_quests_starts)
	# ending tests
	assert_true(travelling_vendor_robby.npc_quests_ends.size() == 1)
	assert_false(travelling_vendor_robby.npc_quests_ends.size() == 0)
	assert_false(travelling_vendor_robby.npc_quests_ends.size() == 2)
	assert_true("5" in travelling_vendor_robby.npc_quests_ends)
	assert_false("4" in travelling_vendor_robby.npc_quests_ends)
	assert_false("6" in travelling_vendor_robby.npc_quests_ends)
	assert_false("4" in travelling_vendor_robby.npc_quests_ends)
	
func check_setup_recruiter_billy():
	assert_true(NpcYsortNode.has_node("RecruiterBilly"))
	assert_has_method(recruiter_billy, "get_npc_quests")
	assert_has_method(recruiter_billy, "set_npc_quests")
	assert_has_method(recruiter_billy, "_on_NPCInteract_pressed")
	assert_true("npc_name" in recruiter_billy)
	assert_true("npc_quests_starts" in recruiter_billy)
	assert_true("npc_quests_ends" in recruiter_billy)
	assert_true("npc_quests_starts" in recruiter_billy.get_npc_quests())
	assert_true("npc_quests_ends" in recruiter_billy.get_npc_quests())
	
	# Recruiter Billy | starts : none | ends : 6
	# starting tests
	assert_true(recruiter_billy.npc_quests_starts.size() == 0)
	assert_false(recruiter_billy.npc_quests_starts.size() == 1)
	assert_false("1" in recruiter_billy.npc_quests_starts)
	assert_false("2" in recruiter_billy.npc_quests_starts)
	# ending tests
	assert_true(recruiter_billy.npc_quests_ends.size() == 1)
	assert_false(recruiter_billy.npc_quests_ends.size() == 0)
	assert_false(recruiter_billy.npc_quests_ends.size() == 2)
	assert_true("6" in recruiter_billy.npc_quests_ends)
	assert_false("5" in recruiter_billy.npc_quests_ends)
	assert_false("7" in recruiter_billy.npc_quests_ends)
	
func check_setup_ender_town_job_board():
	assert_true(NpcYsortNode.has_node("EnderTownJobBoard"))
	assert_has_method(ender_town_job_board, "get_npc_quests")
	assert_has_method(ender_town_job_board, "set_npc_quests")
	assert_has_method(ender_town_job_board, "_on_NPCInteract_pressed")
	assert_true("npc_name" in ender_town_job_board)
	assert_true("npc_quests_starts" in ender_town_job_board)
	assert_true("npc_quests_ends" in ender_town_job_board)
	assert_true("npc_quests_starts" in ender_town_job_board.get_npc_quests())
	assert_true("npc_quests_ends" in ender_town_job_board.get_npc_quests())
	
	# Ender Town Job Board| starts : 7, 1001, 1002, 1003 | ends : 7, 1001, 1002, 1003
	# starting tests
	assert_true(ender_town_job_board.npc_quests_starts.size() == 4)
	assert_false(ender_town_job_board.npc_quests_starts.size() == 3)
	assert_false(ender_town_job_board.npc_quests_starts.size() == 5)
	assert_true("7" in ender_town_job_board.npc_quests_starts)
	assert_true("1001" in ender_town_job_board.npc_quests_starts)
	assert_true("1002" in ender_town_job_board.npc_quests_starts)
	assert_true("1003" in ender_town_job_board.npc_quests_starts)
	assert_false("1101" in ender_town_job_board.npc_quests_starts)
	assert_false("4" in ender_town_job_board.npc_quests_starts)
	# ending tests
	assert_true(ender_town_job_board.npc_quests_ends.size() == 4)
	assert_false(ender_town_job_board.npc_quests_ends.size() == 3)
	assert_false(ender_town_job_board.npc_quests_ends.size() == 5)
	assert_true("7" in ender_town_job_board.npc_quests_ends)
	assert_true("1001" in ender_town_job_board.npc_quests_ends)
	assert_true("1002" in ender_town_job_board.npc_quests_ends)
	assert_true("1003" in ender_town_job_board.npc_quests_ends)
	assert_false("1101" in ender_town_job_board.npc_quests_ends)
	assert_false("4" in ender_town_job_board.npc_quests_ends)

func setup_player():
	player = KinematicBody2D.new()
	player.name = "Player"
	player.script = load("res://Scenes/Player/Player_TESTING.gd") 
	add_child(player)
	player.player_quests.set_player_quests(player.player_quests.get_player_quests(), empty_player_quest_state)
	
func check_setup_player():
	# checking player set up (only works for quests right now)
	assert_has_method(get_node("Player"), "set_quests")
	assert_has_method(get_node("Player"), "get_quests")
	assert_true("player_quests" in get_node("Player"))
	assert_true("player_stats" in get_node("Player"))
		#check initial quest state is empty
	assert_eq_deep(player.player_quests.get_player_quests(), empty_player_quest_state)

