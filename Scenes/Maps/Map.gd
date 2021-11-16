extends Node2D

const interpolation_offset = 100

var tracks : Array = []
var track_playing : int = 0
var dir : Directory = Directory.new()
var turn_on_background_music : bool = true
var g = ServerInterface
var enemy_spawn
var last_world_state = 0
var world_state_buffer = []
var item_textures : Dictionary = {}

var slime = preload("res://Scenes/Enemies/Slime.tscn")
var mino = preload("res://Scenes/Enemies/Mino.tscn")
var player_spawn = preload("res://Scenes/Player/PlayerTemplate.tscn")
var client_player = preload("res://Scenes/Player/Player.tscn")
var item_drop = preload("res://Scenes/Props/ItemGround.tscn")

onready var background_music = get_node("BackgroundMusic")


func _ready():
	#get a list of the background tracks
	dir.open("res://Assets/Sounds/Background Music/")
	dir.list_dir_begin(true, true)
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".import"):
			tracks.append(file.split(".import")[0])	
	load_item_textures()
	Enemies.register_map(self)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.is_action_pressed("NextBackgroundMusic"):
			next_background_music_track()
		if event.pressed and event.is_action_pressed("PreviousBackgroundMusic"):
			previous_background_music_track()
		if event.pressed and event.is_action_pressed("Inventory"):
			open_close_inventory()


func open_close_inventory():
	if $GUI/Inventory.visible == true:
		$GUI/Inventory.visible = false
		$GUI/Inventory.reset_inventory_layout()
	else:
		$GUI/Inventory.visible = true			

func play_background_music():
	background_music.stream = load("res://Assets/Sounds/Background Music/" + tracks[track_playing])
	if turn_on_background_music:
		background_music.play()
	Logger.info("Track name: " + str(tracks[track_playing]) + "   Track Number: " + str(track_playing))

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
	$GUI/Inventory.set_player_character(client_player_instance.get_character_base())

func spawn_new_player(player_id : int, spawn_position : Vector2):
	if get_tree().get_network_unique_id() == player_id:
		pass
	else:
		if Players.has(player_id):
			return
		
		var new_player = player_spawn.instance()
		new_player.position = spawn_position
		new_player.name = str(player_id)
		Players.add_player_node(player_id, new_player)
		get_node("YSort/OtherPlayers").add_child(new_player)

func spawn_enemy(new_enemy):
	get_node("YSort/Enemies/").add_child(new_enemy, true)

func despawn_player(player_id : int):
	yield(get_tree().create_timer(0.3), "timeout")
	Logger.info("despawning", " ", player_id)
	Players.erase(player_id)

func update_world_state(world_state : Dictionary):
	if world_state[g.TIMESTAMP] > last_world_state:
		last_world_state = world_state[g.TIMESTAMP]
		world_state_buffer.append(world_state)

func drop_item(item_id : int, item_name : String, item_position : Vector2, tagged_by_player : int):
	var new_item_drop = item_drop.instance()
	new_item_drop.name = item_name
	new_item_drop.item_id = item_id
	new_item_drop.position = item_position
	new_item_drop.tagged_by_player = tagged_by_player
	new_item_drop.item_texture = item_textures[int(item_id)]
	new_item_drop.connect("pickup", $GUI/Inventory, "on_pickup")
	get_node("YSort/Items").add_child(new_item_drop)

func load_item_textures():
	dir.open("res://Assets/inventory/Items/")
	dir.list_dir_begin(true, true)
	#get all files that end in .png from the directory above
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with(".import") and file[0].to_int() != 0:
			var id = file.to_int()
			item_textures[id] =  load("res://Assets/inventory/Items/" + file.split(".import")[0])
	
func _physics_process(_delta):
	var render_time : float = Server.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
			
		if world_state_buffer.size() > 2:
			var inperpolation_factor : float = float(render_time - world_state_buffer[1][g.TIMESTAMP]) / float(world_state_buffer[2][g.TIMESTAMP] - world_state_buffer[0][g.TIMESTAMP])
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
				if Players.has(player):
					var new_position : Vector2 = lerp(world_state_buffer[1][player][g.PLAYER_POSITION], world_state_buffer[2][player][g.PLAYER_POSITION], inperpolation_factor)
					var animation_vector : Vector2 = world_state_buffer[2][player][g.PLAYER_ANIMATION_VECTOR]
					Players.get_player_node(player).move_player(new_position, animation_vector)
				else:
					Logger.info("spawning other player")
					spawn_new_player(player, world_state_buffer[2][player][g.PLAYER_POSITION])
			for enemy_id in world_state_buffer[2][g.ENEMIES].keys(): 
				if not world_state_buffer[1][g.ENEMIES].has(enemy_id): #if you find enemy in this world state but wasnt in previous world state (15ms before) do nothing #15 10:00
					continue
				var enemy = Enemies.get_enemy(enemy_id)
				if enemy:
					var new_position : Vector2 = lerp(world_state_buffer[1][g.ENEMIES][enemy_id][g.ENEMY_LOCATION], world_state_buffer[2][g.ENEMIES][enemy_id][g.ENEMY_LOCATION], inperpolation_factor)
					enemy.MoveEnemy(new_position)
					enemy.Health(world_state_buffer[1][g.ENEMIES][enemy_id][g.ENEMY_CURRENT_HEALTH])
			
			for ore in world_state_buffer[2][g.ORES].keys():
				if world_state_buffer[2][g.ORES][ore][g.PLAYER_ANIMATION_VECTOR] == 0:
					get_node("YSort/Ores/" + str(ore) + "/Sprite").frame = 0
				else:
					get_node("YSort/Ores/" + str(ore) + "/Sprite").frame = 1 
								
		elif render_time > world_state_buffer[1].T: #we have no future world state
			var extrapolation_factor : float = float(render_time - world_state_buffer[0][g.TIMESTAMP]) / float(world_state_buffer[1][g.TIMESTAMP] - world_state_buffer[0][g.TIMESTAMP]) - 1.00
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
				if Players.has(player):		
					var position_delta : Vector2 = (world_state_buffer[1][player][g.PLAYER_POSITION] - world_state_buffer[0][player][g.PLAYER_POSITION])
					var new_position : Vector2 = world_state_buffer[1][player][g.PLAYER_POSITION] + (position_delta * extrapolation_factor)
					var animation_vector : Vector2 = world_state_buffer[1][player][g.PLAYER_ANIMATION_VECTOR]
					Players.get_player_node(player).move_player(new_position, animation_vector)
			for enemy_id in world_state_buffer[1][g.ENEMIES].keys(): 
				if not world_state_buffer[0][g.ENEMIES].has(enemy_id): #if you find enemy in this world state but wasnt in previous world state (15ms before) do nothing #15 10:00
					continue
				var enemy = Enemies.get_enemy(enemy_id)
				if enemy:
					var position_delta : Vector2 = ((world_state_buffer[1][g.ENEMIES][enemy_id][g.ENEMY_LOCATION] - world_state_buffer[0][g.ENEMIES][enemy_id][g.ENEMY_LOCATION]))
					var new_position : Vector2 = world_state_buffer[1][g.ENEMIES][enemy_id][g.ENEMY_LOCATION] + (position_delta * extrapolation_factor)
					enemy.MoveEnemy(new_position)
					enemy.Health(world_state_buffer[1][g.ENEMIES][enemy_id][g.ENEMY_CURRENT_HEALTH])

func _on_InventoryButton_pressed() -> void:
	open_close_inventory()
	$GUI/InventoryButton.release_focus()


func _on_NextTrackButton_pressed() -> void:
	next_background_music_track()
	$GUI/NextTrackButton.release_focus()


func _on_PreviousTrackButton_pressed() -> void:
	previous_background_music_track()
	$GUI/PreviousTrackButton.release_focus()


func _on_VolumeSlider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear2db(value))

