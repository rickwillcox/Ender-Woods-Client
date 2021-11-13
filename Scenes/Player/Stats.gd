extends Node

export var Experience : int setget Experience_set, Experience_get
export var Level : int setget Level_set, Level_get
export var Max_Health : int setget Max_Health_set, Max_Health_get
export var Current_Health : int setget Current_Health_set, Current_Health_get
export var Max_Mana : int setget Max_Mana_set, Max_Mana_get
export var Current_Mana : int setget Current_Mana_set, Current_Mana_get
export var Strength : int setget Strength_set, Strength_get
export var Vitality : int setget Vitality_set, Vitality_get
export var Wisdom : int setget Wisdom_set, Wisdom_get
export var Willpower : int setget Willpower_set, Willpower_get
export var Dexterity : int setget Dexterity_set, Dexterity_get
export var Agility : int setget Agility_set, Agility_get
export var Luck : int setget Luck_set, Luck_get
export var Attack : int setget Attack_set, Attack_get
export var Defense : int setget Defense_set, Defense_get
export var Magic_Attack : int setget Magic_Attack_set, Magic_Attack_get
export var Magic_Defense : int setget Magic_Defense_set, Magic_Defense_get
export var Attack_Speed : int setget Attack_Speed_set, Attack_Speed_get
export var Hit_Chance : int setget Hit_Chance_set, Hit_Chance_get
export var Evasion : int setget Evasion_set, Evasion_get
export var Critical_Chance : int setget Critical_Chance_set, Critical_Chance_get
export var Critical_Multiplier : int setget Critical_Multiplier_set, Critical_Multiplier_get
export var Critical_Evade : int setget Critical_Evade_set, Critical_Evade_get
export var Magic_Evade : int setget Magic_Evade_set, Magic_Evade_get
export var Magic_Reflect : int setget Magic_Reflect_set, Magic_Reflect_get
export var Counter : int setget Counter_set, Counter_get
export var Health_Regeneration : int setget Health_Regeneration_set, Health_Regeneration_get
export var Mana_Regeneration : int setget Mana_Regeneration_set, Mana_Regeneration_get

var Max_Health_formula = "50*level + 25"

signal Stat_value_changed(stat, value)
signal Health_changed(value)
signal Mana_changed(value)

func _ready():
	Max_Health_calc(5)

func Experience_set(value):
	Experience = value
	emit_signal("Stat_value_changed", "Experience", value)

func Experience_get():
	return Experience

func Level_set(value):
	Level = value
	emit_signal("Stat_value_changed", "Level", value)
func Level_get():
	return Level

func Max_Health_set(value):
	Max_Health = value
	emit_signal("Stat_value_changed", "Max_Health", value)
func Max_Health_get():
	return Max_Health
func Max_Health_calc(level = Level):
	var expression_string = Max_Health_formula
	expression_string.replace("level", str(level))
	var expression = Expression.new()
	return expression.parse(expression_string)

func Current_Health_set(value):
	Current_Health = clamp(value, 0, Max_Health)
	emit_signal("Health_changed", value)
func Current_Health_get():
	return Current_Health

func Max_Mana_set(value):
	Max_Mana = value
	emit_signal("Stat_value_changed", "Max_Mana", value)
func Max_Mana_get():
	return Max_Mana

func Current_Mana_set(value):
	Current_Mana = clamp(value, 0, Max_Mana)
	emit_signal("Mana_changed", value)
func Current_Mana_get():
	return Current_Mana

func Strength_set(value):
	Strength = value
	emit_signal("Stat_value_changed", "Strength", value)
func Strength_get():
	return Strength

func Vitality_set(value):
	Vitality = value
	emit_signal("Stat_value_changed", "Vitality", value)
func Vitality_get():
	return Vitality

func Wisdom_set(value):
	Wisdom = value
	emit_signal("Stat_value_changed", "Wisdom", value)
func Wisdom_get():
	return Wisdom

func Willpower_set(value):
	Willpower = value
	emit_signal("Stat_value_changed", "Willpower", value)
func Willpower_get():
	return Willpower

func Dexterity_set(value):
	Dexterity = value
	emit_signal("Stat_value_changed", "Dexterity", value)
func Dexterity_get():
	return Dexterity

func Agility_set(value):
	Agility = value
	emit_signal("Stat_value_changed", "Agility", value)
func Agility_get():
	return Agility

func Luck_set(value):
	Luck = value
	emit_signal("Stat_value_changed", "Luck", value)
func Luck_get():
	return Luck

func Attack_set(value):
	Attack = value
	emit_signal("Stat_value_changed", "Attack", value)
func Attack_get():
	return Attack

func Defense_set(value):
	Defense = value
	emit_signal("Stat_value_changed", "Defense", value)
func Defense_get():
	return Defense

func Magic_Attack_set(value):
	Magic_Attack = value
	emit_signal("Stat_value_changed", "Magic_Attack", value)
func Magic_Attack_get():
	return Magic_Attack

func Magic_Defense_set(value):
	Magic_Defense = value
	emit_signal("Stat_value_changed", "Magic_Defense", value)
func Magic_Defense_get():
	return Magic_Defense

func Attack_Speed_set(value):
	Attack_Speed = value
	emit_signal("Stat_value_changed", "Attack_Speed", value)
func Attack_Speed_get():
	return Attack_Speed

func Hit_Chance_set(value):
	Hit_Chance = value
	emit_signal("Stat_value_changed", "Hit_Chance", value)
func Hit_Chance_get():
	return Hit_Chance

func Evasion_set(value):
	Evasion = value
	emit_signal("Stat_value_changed", "Evasion", value)
func Evasion_get():
	return Evasion

func Critical_Chance_set(value):
	Critical_Chance = value
	emit_signal("Stat_value_changed", "Critical_Chance", value)
func Critical_Chance_get():
	return Critical_Chance

func Critical_Multiplier_set(value):
	Critical_Multiplier = value
	emit_signal("Stat_value_changed", "Critical_Multiplier", value)
func Critical_Multiplier_get():
	return Critical_Multiplier

func Critical_Evade_set(value):
	Critical_Evade = value
	emit_signal("Stat_value_changed", "Critical_Evade", value)
func Critical_Evade_get():
	return Critical_Evade

func Magic_Evade_set(value):
	Magic_Evade = value
	emit_signal("Stat_value_changed", "Magic_Evade", value)
func Magic_Evade_get():
	return Magic_Evade

func Magic_Reflect_set(value):
	Magic_Reflect = value
	emit_signal("Stat_value_changed", "Magic_Reflect", value)
func Magic_Reflect_get():
	return Magic_Reflect

func Counter_set(value):
	Counter = value
	emit_signal("Stat_value_changed", "Counter", value)
func Counter_get():
	return Counter

func Health_Regeneration_set(value):
	Health_Regeneration = value
	emit_signal("Stat_value_changed", "Health_Regeneration", value)
func Health_Regeneration_get():
	return Health_Regeneration

func Mana_Regeneration_set(value):
	Mana_Regeneration = value
	emit_signal("Stat_value_changed", "Mana_Regeneration", value)
func Mana_Regeneration_get():
	return Mana_Regeneration
