extends Node

var storage = {}
var si = ServerInterface

var floating_number = preload("res://Scenes/UI/FloatingNumber.tscn")
var slime = preload("res://Scenes/Enemies/Slime.tscn")
var mino = preload("res://Scenes/Enemies/Mino.tscn")
var batsquito = preload("res://Scenes/Enemies/Batsquito.tscn")
var map

func _ready():
	PacketHandler.connect("enemy_spawn", self, "handle_enemy_spawn")
	PacketHandler.connect("enemy_died", self, "handle_enemy_died")
	PacketHandler.connect("enemy_despawn", self, "handle_enemy_despawn")
	PacketHandler.connect("enemy_swing", self, "handle_enemy_swing")
	PacketHandler.connect("enemy_take_damage", self, "handle_enemy_take_damage")

func register_map(new_map):
	map = new_map

func handle_enemy_spawn(enemy_id, state, enemy_type, health, position):
	if enemy_id in storage:
		assert(false)
	var enemy = instance_enemy(enemy_type)
	storage[enemy_id] = enemy
	map.spawn_enemy(enemy)
	if state == si.EnemyState.DEAD:
		enemy.OnDeath()

func handle_enemy_died(enemy_id):
	if enemy_id in storage:
		storage[enemy_id].OnDeath()

func handle_enemy_despawn(enemy_id):
	if enemy_id in storage:
		storage[enemy_id].queue_free()
		storage.erase(enemy_id)

func instance_enemy(enemy_type):
	var result = null
	match enemy_type:
		si.EnemyType.MINO:
			result = mino.instance()
		si.EnemyType.SLIME:
			result = slime.instance()
		si.EnemyType.BATSQUITO:
			result = batsquito.instance()
		_:
			# not implemented enemy type
			assert(false)
	return result

func get_enemy(enemy_id):
	if storage.has(enemy_id):
		return storage[enemy_id]
	return null

func handle_enemy_swing(enemy_id, victim_id):
	if storage.has(enemy_id):
		storage[enemy_id].swing_at(victim_id)


func handle_enemy_take_damage(enemy_id : int, damage : int):
	if storage.has(enemy_id):
		var floating_damage = floating_number.instance()
		floating_damage.set_value(damage)
		floating_damage.position = storage[enemy_id].position - Vector2(0, -30)
		map.add_child(floating_damage)
