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

var Formulas = {}
var Experience_Curve = []

signal Stat_value_changed(stat, value)
signal Health_changed(value)
signal Mana_changed(value)
signal Level_Up(value)

func _ready(): #ready requests Formulas and Experience
	temporaty_local_curves() #this will be removed when Formulas_request() is ready
	Formulas_request()
	Experience_request()
	Experience_init_curve()
	Experience_set(500) #Test Experience
	Refresh_Base_Stats() #Call this function after Formula and Experience have been defined


func Refresh_Base_Stats():
	#Call this function after Formula and Experience have been defined
	Level_set(Level_calc()) #Set Level from Experience
	#Set Teir 0 from Level
	Max_Health_set(Max_Health_calc())
	Current_Health_set(Max_Health_get()) #This could be changed if we want to pull health from server
	Max_Mana_set(Max_Mana_calc())
	Current_Mana_set(Max_Mana_get())
	#Set Teir 1 from Level
	Strength_set(Strength_calc())
	Vitality_set(Vitality_calc())
	Wisdom_set(Wisdom_calc())
	Willpower_set(Willpower_calc())
	Dexterity_set(Dexterity_calc())
	Agility_set(Agility_calc())
	Luck_set(Luck_calc())
	#Set Teir 2 from Teir 1
	Attack_set(Attack_calc())
	Defense_set(Defense_calc())
	Magic_Attack_set(Magic_Attack_calc())
	Magic_Defense_set(Magic_Defense_calc())
	Attack_Speed_set(Attack_Speed_calc())
	Hit_Chance_set(Hit_Chance_calc())
	Evasion_set(Evasion_calc())
	Critical_Chance_set(Critical_Chance_calc())
	Critical_Multiplier_set(Critical_Multiplier_calc())
	Critical_Evade_set(Critical_Evade_calc())
	Magic_Evade_set(Magic_Evade_calc())
	Magic_Reflect_set(Magic_Reflect_calc())
	Counter_set(Counter_calc())
	Health_Regeneration_set(Health_Regeneration_calc())
	Mana_Regeneration_set(Mana_Regeneration_calc())


func Formulas_request():
	#Send RPC to server to get formula curve table and recieve it via Formulas_receive
	pass
remote func Formulas_receive(Curves):
	Formulas = Curves
func temporaty_local_curves():
	Formulas["Experience"] = "(pow((2 * LEVEL), 3)) + (8 * LEVEL) + 200"
	Formulas["Max_Health"] = "50 * LEVEL + 25"
	Formulas["Max_Mana"] = "50 * LEVEL + 25"
	Formulas["Strength"] = "3 * LEVEL"
	Formulas["Vitality"] = "3 * LEVEL"
	Formulas["Wisdom"] = "3 * LEVEL"
	Formulas["Willpower"] = "3 * LEVEL"
	Formulas["Dexterity"] = "3 * LEVEL"
	Formulas["Agility"] = "3 * LEVEL"
	Formulas["Luck"] = "3 * LEVEL"
	Formulas["Attack"] = "1 * STR"
	Formulas["Defense"] = "1 * VIT"
	Formulas["Magic_Attack"] = "1 * WIS"
	Formulas["Magic_Defense"] = "1 * WIL"
	Formulas["Attack_Speed"] = "DEX / 100"
	Formulas["Hit_Chance"] = "(DEX / 5) + 25"
	Formulas["Evasion"] = "AGI / 3"
	Formulas["Critical_Chance"] = "((2 * DEX) + (LUK / 3)) / 10"
	Formulas["Critical_Multiplier"] = "((AGI + DEX + LUK) / 3) + 25"
	Formulas["Critical_Evade"] = "((2 * AGI) + LUK) / 25"
	Formulas["Magic_Evade"] = "((2 * WIL) + LUK) / 25"
	Formulas["Magic_Reflect"] = "LEVEL"
	Formulas["Counter"] = "DEX / 15"
	Formulas["Health_Regeneration"] = "(5 * VIT) / 150"
	Formulas["Mana_Regeneration"] = "(5 * WIL) / 150"


#EXPERIENCE
func Experience_request():
	#RPC for experience of player
	pass
remote func Experience_recieve(EXP):
	Experience_set(EXP)
func Experience_set(value):
	Experience = value
	emit_signal("Stat_value_changed", "Experience", value)
func Experience_get():
	return Experience
func Experience_init_curve():
	Experience_Curve = []
	for i in 100:
		var expression = Expression.new()
		var error = expression.parse(Formulas.Experience, ["LEVEL"])
		if error != OK:
			Logger.error(expression.get_error_text())
			return
		var result = expression.execute([i + 1])
		if not expression.has_execute_failed():
			Experience_Curve.append(result)
		else:
			Logger.error("Level Formula is invalid")


#LEVEL
func Level_set(value):
	if value > Level and Level != null:
		Level = value
		emit_signal("Level_Up", value)
	else:
		Level = value
		emit_signal("Stat_value_changed", "Level", value)
func Level_get():
	return Level
func Level_calc(EXP = Experience):
	var index = 0
	for level_req in Experience_Curve:
		if EXP < level_req:
			return index
		else:
			index += 1


#HEALTH
func Max_Health_set(value):
	Max_Health = value
	emit_signal("Stat_value_changed", "Max_Health", value)
func Max_Health_get():
	return Max_Health
func Max_Health_calc(level = Level):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Max_Health, ["LEVEL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([level])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Max Health Formula is invalid")
func Current_Health_set(value):
# warning-ignore:narrowing_conversion
	Current_Health = clamp(value, 0, Max_Health)
	emit_signal("Health_changed", value)
func Current_Health_get():
	return Current_Health


#MANA
func Max_Mana_set(value):
	Max_Mana = value
	emit_signal("Stat_value_changed", "Max_Mana", value)
func Max_Mana_get():
	return Max_Mana
func Max_Mana_calc(level = Level):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Max_Mana, ["LEVEL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([level])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Max Mana Formula is invalid")
func Current_Mana_set(value):
# warning-ignore:narrowing_conversion
	Current_Mana = clamp(value, 0, Max_Mana)
	emit_signal("Mana_changed", value)
func Current_Mana_get():
	return Current_Mana


#STRENGTH
func Strength_set(value):
	Strength = value
	emit_signal("Stat_value_changed", "Strength", value)
func Strength_get():
	return Strength
func Strength_calc(level = Level):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Strength, ["LEVEL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([level])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Strength Formula is invalid")

#VITALITY
func Vitality_set(value):
	Vitality = value
	emit_signal("Stat_value_changed", "Vitality", value)
func Vitality_get():
	return Vitality
func Vitality_calc(level = Level):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Vitality, ["LEVEL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([level])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Vitality Formula is invalid")

#WISDOM
func Wisdom_set(value):
	Wisdom = value
	emit_signal("Stat_value_changed", "Wisdom", value)
func Wisdom_get():
	return Wisdom
func Wisdom_calc(level = Level):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Wisdom, ["LEVEL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([level])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Wisdom Formula is invalid")

#WILLPOWER
func Willpower_set(value):
	Willpower = value
	emit_signal("Stat_value_changed", "Willpower", value)
func Willpower_get():
	return Willpower
func Willpower_calc(level = Level):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Willpower, ["LEVEL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([level])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Willpower Formula is invalid")

#DEXERITY
func Dexterity_set(value):
	Dexterity = value
	emit_signal("Stat_value_changed", "Dexterity", value)
func Dexterity_get():
	return Dexterity
func Dexterity_calc(level = Level):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Dexterity, ["LEVEL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([level])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Dexterity Formula is invalid")

#AGILITY
func Agility_set(value):
	Agility = value
	emit_signal("Stat_value_changed", "Agility", value)
func Agility_get():
	return Agility
func Agility_calc(level = Level):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Agility, ["LEVEL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([level])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Agility Formula is invalid")

#LUCK
func Luck_set(value):
	Luck = value
	emit_signal("Stat_value_changed", "Luck", value)
func Luck_get():
	return Luck
func Luck_calc(level = Level):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Luck, ["LEVEL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([level])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Luck Formula is invalid")

#ATTACK
func Attack_set(value):
	Attack = value
	emit_signal("Stat_value_changed", "Attack", value)
func Attack_get():
	return Attack
func Attack_calc(STR = Strength):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Attack, ["STR"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([STR])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Attack Formula is invalid")

#DEFENSE
func Defense_set(value):
	Defense = value
	emit_signal("Stat_value_changed", "Defense", value)
func Defense_get():
	return Defense
func Defense_calc(VIT = Vitality):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Defense, ["VIT"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([VIT])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Defense Formula is invalid")

#MAGIC ATTACK
func Magic_Attack_set(value):
	Magic_Attack = value
	emit_signal("Stat_value_changed", "Magic_Attack", value)
func Magic_Attack_get():
	return Magic_Attack
func Magic_Attack_calc(WIS = Wisdom):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Magic_Attack, ["WIS"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([WIS])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Magic Attack Formula is invalid")

#MAGIC DEFENSE
func Magic_Defense_set(value):
	Magic_Defense = value
	emit_signal("Stat_value_changed", "Magic_Defense", value)
func Magic_Defense_get():
	return Magic_Defense
func Magic_Defense_calc(WIL = Willpower):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Magic_Defense, ["WIL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([WIL])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Magic Defense Formula is invalid")

#ATTACK SPEED
func Attack_Speed_set(value):
	Attack_Speed = value
	emit_signal("Stat_value_changed", "Attack_Speed", value)
func Attack_Speed_get():
	return Attack_Speed
func Attack_Speed_calc(DEX = Dexterity):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Attack_Speed, ["DEX"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([DEX])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Attack Speed Formula is invalid")

#HIT CHANCE
func Hit_Chance_set(value):
	Hit_Chance = value
	emit_signal("Stat_value_changed", "Hit_Chance", value)
func Hit_Chance_get():
	return Hit_Chance
func Hit_Chance_calc(DEX = Dexterity):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Hit_Chance, ["DEX"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([DEX])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Hit Chance Formula is invalid")

#EVASION
func Evasion_set(value):
	Evasion = value
	emit_signal("Stat_value_changed", "Evasion", value)
func Evasion_get():
	return Evasion
func Evasion_calc(AGI = Agility):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Evasion, ["AGI"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([AGI])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Evasion Formula is invalid")


#CRITICAL CHANCE
func Critical_Chance_set(value):
	Critical_Chance = value
	emit_signal("Stat_value_changed", "Critical_Chance", value)
func Critical_Chance_get():
	return Critical_Chance
func Critical_Chance_calc(DEX = Dexterity, LUK = Luck):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Critical_Chance, ["DEX", "LUK"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([DEX, LUK])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Critical Chance Formula is invalid")

#CRITICAL MULTIPLIER
func Critical_Multiplier_set(value):
	Critical_Multiplier = value
	emit_signal("Stat_value_changed", "Critical_Multiplier", value)
func Critical_Multiplier_get():
	return Critical_Multiplier
func Critical_Multiplier_calc(AGI = Agility, DEX = Dexterity, LUK = Luck):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Critical_Multiplier, ["AGI", "DEX", "LUK"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([AGI, DEX, LUK])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Critical Multiplier Formula is invalid")

#CRITICAL EVADE
func Critical_Evade_set(value):
	Critical_Evade = value
	emit_signal("Stat_value_changed", "Critical_Evade", value)
func Critical_Evade_get():
	return Critical_Evade
func Critical_Evade_calc(AGI = Agility, LUK = Luck):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Critical_Evade, ["AGI", "LUK"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([AGI, LUK])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Critical Evade Formula is invalid")

#MAGIC EVADE
func Magic_Evade_set(value):
	Magic_Evade = value
	emit_signal("Stat_value_changed", "Magic_Evade", value)
func Magic_Evade_get():
	return Magic_Evade
func Magic_Evade_calc(WIL = Willpower, LUK = Luck):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Magic_Evade, ["WIL", "LUK"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([WIL, LUK])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Magic Evade Formula is invalid")

#MAGIC REFLECT
func Magic_Reflect_set(value):
	Magic_Reflect = value
	emit_signal("Stat_value_changed", "Magic_Reflect", value)
func Magic_Reflect_get():
	return Magic_Reflect
func Magic_Reflect_calc(level = Level):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Magic_Reflect, ["LEVEL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([level])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Agility Formula is invalid")

#COUNTER
func Counter_set(value):
	Counter = value
	emit_signal("Stat_value_changed", "Counter", value)
func Counter_get():
	return Counter
func Counter_calc(DEX = Dexterity):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Counter, ["DEX"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([DEX])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Counter Formula is invalid")

#HEALTH REGENERATION
func Health_Regeneration_set(value):
	Health_Regeneration = value
	emit_signal("Stat_value_changed", "Health_Regeneration", value)
func Health_Regeneration_get():
	return Health_Regeneration
func Health_Regeneration_calc(VIT = Vitality):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Health_Regeneration, ["VIT"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([VIT])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Health Regeneration Formula is invalid")

#MANA REGENERATION
func Mana_Regeneration_set(value):
	Mana_Regeneration = value
	emit_signal("Stat_value_changed", "Mana_Regeneration", value)
func Mana_Regeneration_get():
	return Mana_Regeneration
func Mana_Regeneration_calc(WIL = Willpower):
	var expression = Expression.new()
	var error = expression.parse(Formulas.Mana_Regeneration, ["WIL"])
	if error != OK:
		Logger.error(expression.get_error_text())
		return
	var result = expression.execute([WIL])
	if not expression.has_execute_failed():
		return result
	else:
		Logger.error("Mana Regeneration Formula is invalid")
