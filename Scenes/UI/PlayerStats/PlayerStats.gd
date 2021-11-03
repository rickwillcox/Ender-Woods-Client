extends Control

onready var level = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer/Level2")
onready var maxhealth = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer3/MaxHealth2")
onready var strength = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer5/Strength2")
onready var dexterity = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer7/Dexterity2")
onready var intelligence = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer10/Intelligence2")
onready var attack = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer11/Attack2")
onready var defense = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer12/Defense2")
onready var crit_chance = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer2/CritChance2")
onready var crit_multi = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer4/CritMulti2")
onready var evasion = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer6/Evasion2")
onready var magic_find = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer8/MagicFind2")
onready var move_speed = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer13/MoveSpeed2")
onready var luck = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer9/Luck2")
onready var lifesteal = get_node("Background/VBoxContainer/HBoxContainer/GridContainer/HBoxContainer14/Lifesteal2")



# Called when the node enters the scene tree for the first time.
func _ready():
	level.text = "15"
	maxhealth.text = "400"
	strength.text = "52"
	dexterity.text = "65"
	intelligence.text = "3"
	attack.text = "87"
	defense.text = "24"
	crit_chance.text = "5"
	crit_multi.text = "50"
	evasion.text = "24"
	magic_find.text = "20"
	move_speed.text = "50"
	luck.text = "10"
	lifesteal.text = "7%"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
