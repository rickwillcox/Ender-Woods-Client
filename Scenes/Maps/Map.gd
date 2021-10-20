extends Node2D

var g = Globals
var enemy_spawn
var slime = preload("res://Scenes/Enemies/Slime.tscn")
var mino = preload("res://Scenes/Enemies/Mino.tscn")
var player_spawn = preload("res://Scenes/Player/PlayerTemplate.tscn")
var client_player = preload("res://Scenes/Player/Player.tscn")
var last_world_state = 0
var world_state_buffer = []
const interpolation_offset = 100
var printed_world_state = false

func SpawnSelf():
	var client_player_instance = client_player.instance()
	client_player_instance.position = Vector2(250,250)
	get_node("YSort").add_child(client_player_instance)

func SpawnNewPlayer(player_id, spawn_position):
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		if not get_node("YSort/OtherPlayers").has_node(str(player_id)):
			var new_player = player_spawn.instance()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			get_node("YSort/OtherPlayers").add_child(new_player)
#
func SpawnNewEnemy(enemy_id, enemy_dict):
	var enemy_type = enemy_dict[g.ENEMY_TYPE]
	if enemy_type == "Slime":
		 enemy_spawn = slime
	elif enemy_type == "Mino":
		enemy_spawn = mino
	var new_enemy = enemy_spawn.instance()
	new_enemy.position = enemy_dict[g.ENEMY_LOCATION]
	new_enemy.max_hp = enemy_dict[g.ENEMY_MAX_HEALTH]
	new_enemy.current_hp = enemy_dict[g.ENEMY_CURRENT_HEALTH]
	new_enemy.type = enemy_dict[g.ENEMY_TYPE]
	new_enemy.state = enemy_dict[g.ENEMY_STATE]
	new_enemy.name = str(enemy_id)
	if new_enemy.current_hp > 0:
		get_node("YSort/Enemies/").add_child(new_enemy, true)

func DespawnPlayer(player_id):
	yield(get_tree().create_timer(0.3), "timeout")
	print(player_id)
	get_node("YSort/OtherPlayers/" + str(player_id)).queue_free()

func UpdateWorldState(world_state):
	if world_state[g.WORLD_STATE_TIMESTAMP] > last_world_state:
		last_world_state = world_state[g.WORLD_STATE_TIMESTAMP]
		world_state_buffer.append(world_state)
		
func _physics_process(_delta):
	var render_time = Server.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
			
		if world_state_buffer.size() > 2:
			var inperpolation_factor = float(render_time - world_state_buffer[1][g.WORLD_STATE_TIMESTAMP]) / float(world_state_buffer[2][g.WORLD_STATE_TIMESTAMP] - world_state_buffer[0][g.WORLD_STATE_TIMESTAMP])
			for player in world_state_buffer[2].keys():
				if str(player) == g.WORLD_STATE_TIMESTAMP:
					continue
				if str(player) == g.WORLD_STATE_ENEMIES:
					continue
				if str(player) == g.WORLD_STATE_ORES:
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if get_node("YSort/OtherPlayers").has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player][g.PLAYER_POSITION], world_state_buffer[2][player][g.PLAYER_POSITION], inperpolation_factor)
					var animation_vector = world_state_buffer[2][player][g.PLAYER_ANIMATION_VECTOR]
					get_node("YSort/OtherPlayers/" + str (player)).MovePlayer(new_position, animation_vector)
				else:
					print("spawning other player")
					SpawnNewPlayer(player, world_state_buffer[2][player][g.PLAYER_POSITION])
			for enemy in world_state_buffer[2][g.WORLD_STATE_ENEMIES].keys(): 
				if not world_state_buffer[1][g.WORLD_STATE_ENEMIES].has(enemy): #if you find enemy in this world state but wasnt in previous world state (15ms before) do nothing #15 10:00
					continue
				if get_node("YSort/Enemies").has_node(str(enemy)): #does enemy exist
					var new_position = lerp(world_state_buffer[1][g.WORLD_STATE_ENEMIES][enemy][g.ENEMY_LOCATION], world_state_buffer[2][g.WORLD_STATE_ENEMIES][enemy][g.ENEMY_LOCATION], inperpolation_factor)
					get_node("YSort/Enemies/" + str(enemy)).MoveEnemy(new_position)
					get_node("YSort/Enemies/" + str(enemy)).Health(world_state_buffer[1][g.WORLD_STATE_ENEMIES][enemy][g.ENEMY_CURRENT_HEALTH])
				else:
					SpawnNewEnemy(enemy, world_state_buffer[2][g.WORLD_STATE_ENEMIES][enemy])
					
			for ore in world_state_buffer[2][g.WORLD_STATE_ORES].keys():
				if world_state_buffer[2][g.WORLD_STATE_ORES][ore][g.PLAYER_ANIMATION_VECTOR] == 0:
					get_node("YSort/Ores/" + str(ore) + "/Sprite").frame = 0
				else:
					get_node("YSort/Ores/" + str(ore) + "/Sprite").frame = 1 
								
		elif render_time > world_state_buffer[1].T: #we have no future world state
			var extrapolation_factor = float(render_time - world_state_buffer[0][g.WORLD_STATE_TIMESTAMP]) / float(world_state_buffer[1][g.WORLD_STATE_TIMESTAMP] - world_state_buffer[0][g.WORLD_STATE_TIMESTAMP]) - 1.00
			for player in world_state_buffer[1].keys():		
				if str(player) == g.WORLD_STATE_TIMESTAMP:
					continue
				if str(player) == g.WORLD_STATE_ENEMIES:
					continue
				if str(player) == g.WORLD_STATE_ORES:
					continue
				if player == get_tree().get_network_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if get_node("YSort/OtherPlayers").has_node(str(player)):		
					var position_delta = (world_state_buffer[1][player][g.PLAYER_POSITION] - world_state_buffer[0][player][g.PLAYER_POSITION])
					var new_position = world_state_buffer[1][player][g.PLAYER_POSITION] + (position_delta * extrapolation_factor)
					var animation_vector = world_state_buffer[1][player][g.PLAYER_ANIMATION_VECTOR]
					get_node("YSort/OtherPlayers/" + str(player)).MovePlayer(new_position, animation_vector)
			for enemy in world_state_buffer[1][g.WORLD_STATE_ENEMIES].keys(): 
				if not world_state_buffer[1][g.WORLD_STATE_ENEMIES].has(enemy): #if you find enemy in this world state but wasnt in previous world state (15ms before) do nothing #15 10:00
					continue
				if get_node("YSort/Enemies").has_node(str(enemy)): #does enemy exist
					var position_delta = ((world_state_buffer[1][g.WORLD_STATE_ENEMIES][enemy][g.ENEMY_LOCATION] - world_state_buffer[0][g.WORLD_STATE_ENEMIES][enemy][g.ENEMY_LOCATION]))
					var new_position = world_state_buffer[1][g.WORLD_STATE_ENEMIES][enemy][g.ENEMY_LOCATION] + (position_delta * extrapolation_factor)
					var state = world_state_buffer[1][g.WORLD_STATE_ENEMIES][enemy][g.ENEMY_STATE]
					get_node("YSort/Enemies/" + str(enemy)).MoveEnemy(new_position)
					get_node("YSort/Enemies/" + str(enemy)).Health(world_state_buffer[1][g.WORLD_STATE_ENEMIES][enemy][g.ENEMY_CURRENT_HEALTH])
				else:
					SpawnNewEnemy(enemy, world_state_buffer[1][g.WORLD_STATE_ENEMIES][enemy])

