extends Node2D

onready var background_music = get_node("BackgroundMusic")
var tracks = []
var track_playing = 0
var dir = Directory.new()
#true = turn on music / false = no music
var turn_on_background_music = false


var g = ServerInterface
var enemy_spawn
var slime = preload("res://Scenes/Enemies/Slime.tscn")
var mino = preload("res://Scenes/Enemies/Mino.tscn")
var player_spawn = preload("res://Scenes/Player/PlayerTemplate.tscn")
var client_player = preload("res://Scenes/Player/Player.tscn")
var item_drop = preload("res://Scenes/Props/ItemGround.tscn")
var last_world_state = 0
var world_state_buffer = []
const interpolation_offset = 100
var printed_world_state = false
var item_textures : Dictionary = {}


func _ready():
	#get a list of the background tracks
	dir.open("res://Assets/Sounds/Background Music/")
	dir.list_dir_begin(true, true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".mp3"):
			tracks.append(file)	
	
	LoadItemTextures()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("NextBackgroundMusic"):
			next_background_music_track()
		if event.pressed and event.is_action_pressed("PreviousBackgroundMusic"):
			previous_background_music_track()
		if event.pressed and event.is_action_pressed("Inventory"):
			$GUI/Inventory.visible = !$GUI/Inventory.visible

func play_background_music():
	background_music.stream = load("res://Assets/Sounds/Background Music/" + tracks[track_playing])
	if turn_on_background_music:
		background_music.play()
	print("Track name: ", tracks[track_playing], "   Track Number: ", track_playing)

func previous_background_music_track():
	if track_playing == 0:
		track_playing = tracks.size() - 1
	else:
		track_playing -= 1
	play_background_music()
	
func next_background_music_track():
	if track_playing == tracks.size() - 1:
		track_playing = 0
	else:
		track_playing += 1
	play_background_music()

func SpawnSelf():
	#start background music
	play_background_music()
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
	#new_enemy.state = enemy_dict[g.ENEMY_STATE]
	new_enemy.name = str(enemy_id)
	if new_enemy.current_hp > 0:
		get_node("YSort/Enemies/").add_child(new_enemy, true)

func DespawnPlayer(player_id):
	yield(get_tree().create_timer(0.3), "timeout")
	print("despawning", " ", player_id)
	get_node("YSort/OtherPlayers/" + str(player_id)).queue_free()

func UpdateWorldState(world_state):
	if world_state[g.TIMESTAMP] > last_world_state:
		last_world_state = world_state[g.TIMESTAMP]
		world_state_buffer.append(world_state)

func DropItem(item_id, item_name, item_position):
	var new_item_drop = item_drop.instance()
	new_item_drop.name = item_name
	new_item_drop.item_id = item_id
	new_item_drop.position = item_position
	new_item_drop.item_texture = item_textures[int(item_id)]
	add_child(new_item_drop)

func LoadItemTextures():
	dir.open("res://Assets/inventory/Items/")
	dir.list_dir_begin(true, true)
	#get all files that end in .png from the directory above
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".png") and file[0].to_int() != 0:
			var id = file.to_int()
			item_textures[id] =  load("res://Assets/inventory/Items/" + file)
	

		
func _physics_process(_delta):
	var render_time = Server.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
			
		if world_state_buffer.size() > 2:
			var inperpolation_factor = float(render_time - world_state_buffer[1][g.TIMESTAMP]) / float(world_state_buffer[2][g.TIMESTAMP] - world_state_buffer[0][g.TIMESTAMP])
			for player in world_state_buffer[2].keys():
				if str(player) == g.TIMESTAMP:
					continue
				if str(player) == g.ENEMIES:
					continue
				if str(player) == g.ORES:
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
			for enemy in world_state_buffer[2][g.ENEMIES].keys(): 
				if not world_state_buffer[1][g.ENEMIES].has(enemy): #if you find enemy in this world state but wasnt in previous world state (15ms before) do nothing #15 10:00
					continue
				if get_node("YSort/Enemies").has_node(str(enemy)): #does enemy exist
					var new_position = lerp(world_state_buffer[1][g.ENEMIES][enemy][g.ENEMY_LOCATION], world_state_buffer[2][g.ENEMIES][enemy][g.ENEMY_LOCATION], inperpolation_factor)
					get_node("YSort/Enemies/" + str(enemy)).MoveEnemy(new_position)
					get_node("YSort/Enemies/" + str(enemy)).Health(world_state_buffer[1][g.ENEMIES][enemy][g.ENEMY_CURRENT_HEALTH])
				else:
					SpawnNewEnemy(enemy, world_state_buffer[2][g.ENEMIES][enemy])
					
			for ore in world_state_buffer[2][g.ORES].keys():
				if world_state_buffer[2][g.ORES][ore][g.PLAYER_ANIMATION_VECTOR] == 0:
					get_node("YSort/Ores/" + str(ore) + "/Sprite").frame = 0
				else:
					get_node("YSort/Ores/" + str(ore) + "/Sprite").frame = 1 
								
		elif render_time > world_state_buffer[1].T: #we have no future world state
			var extrapolation_factor = float(render_time - world_state_buffer[0][g.TIMESTAMP]) / float(world_state_buffer[1][g.TIMESTAMP] - world_state_buffer[0][g.TIMESTAMP]) - 1.00
			for player in world_state_buffer[1].keys():		
				if str(player) == g.TIMESTAMP:
					continue
				if str(player) == g.ENEMIES:
					continue
				if str(player) == g.ORES:
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
			for enemy in world_state_buffer[1][g.ENEMIES].keys(): 
				if not world_state_buffer[0][g.ENEMIES].has(enemy): #if you find enemy in this world state but wasnt in previous world state (15ms before) do nothing #15 10:00
					continue
				if get_node("YSort/Enemies").has_node(str(enemy)): #does enemy exist
					var position_delta = ((world_state_buffer[1][g.ENEMIES][enemy][g.ENEMY_LOCATION] - world_state_buffer[0][g.ENEMIES][enemy][g.ENEMY_LOCATION]))
					var new_position = world_state_buffer[1][g.ENEMIES][enemy][g.ENEMY_LOCATION] + (position_delta * extrapolation_factor)
					var state = world_state_buffer[1][g.ENEMIES][enemy][g.ENEMY_STATE]
					get_node("YSort/Enemies/" + str(enemy)).MoveEnemy(new_position)
					get_node("YSort/Enemies/" + str(enemy)).Health(world_state_buffer[1][g.ENEMIES][enemy][g.ENEMY_CURRENT_HEALTH])
				else:
					SpawnNewEnemy(enemy, world_state_buffer[1][g.ENEMIES][enemy])

