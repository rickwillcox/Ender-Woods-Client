extends Control


var Player_Stats

func _ready():
	Player_Stats = get_player_stats()
	refresh_stats()
	if Player_Stats != null:
		Player_Stats.connect("Stat_value_changed", self, "_Stat_value_changed")
		Player_Stats.connect("Health_changed", self, "_HPMP_value_changed")
		Player_Stats.connect("Mana_changed", self, "_HPMP_value_changed")


func get_player_stats():
	return PlayerInfo.stats

func _Stat_value_changed(_stat, _value):
	refresh_stats()

func _HPMP_value_changed(_value):
	refresh_stats()

func refresh_stats():
	if Player_Stats == null:
		Logger.error("No Player_Stats was loaded to StatContainer")
	else:
		#Teir 0
		$ScrollContainer/VBoxContainer/Teir1/Values/HP_value.text = "%s/%s" % [Player_Stats.Current_Health_get(), Player_Stats.Max_Health_get()]
		$ScrollContainer/VBoxContainer/Teir1/Values/MP_value.text = "%s/%s" % [Player_Stats.Current_Mana_get(), Player_Stats.Max_Mana_get()]
		#Teir 1
		$ScrollContainer/VBoxContainer/Teir1/Values/STR_value.text = "%s" % Player_Stats.Strength_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/VIT_value.text = "%s" % Player_Stats.Vitality_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/WIS_value.text = "%s" % Player_Stats.Wisdom_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/WIL_value.text = "%s" % Player_Stats.Willpower_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/DEX_value.text = "%s" % Player_Stats.Dexterity_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/AGI_value.text = "%s" % Player_Stats.Agility_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/LUK_value.text = "%s" % Player_Stats.Luck_get()
		#Teir 2
		$ScrollContainer/VBoxContainer/Teir2/Values/ATK_value.text = "%s" % Player_Stats.Attack_get()
		$ScrollContainer/VBoxContainer/Teir2/Values/DEF_value.text = "%s" % Player_Stats.Defense_get()
		$ScrollContainer/VBoxContainer/Teir2/Values/MAT_value.text = "%s" % Player_Stats.Magic_Attack_get()
		$ScrollContainer/VBoxContainer/Teir2/Values/MDF_value.text = "%s" % Player_Stats.Magic_Defense_get()
		$ScrollContainer/VBoxContainer/Teir2/Values/APS_value.text = "%s" % Player_Stats.Attack_Speed_get()
		#Teir 3
		$ScrollContainer/VBoxContainer/Teir3/Values/HIT_value.text = "%s" % Player_Stats.Hit_Chance_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/EVA_value.text = "%s" % Player_Stats.Evasion_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/CRT_value.text = "%s" % Player_Stats.Critical_Chance_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/CRM_value.text = "%s" % Player_Stats.Critical_Multiplier_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/CRE_value.text = "%s" % Player_Stats.Critical_Evade_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/MEV_value.text = "%s" % Player_Stats.Magic_Evade_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/MGR_value.text = "%s" % Player_Stats.Magic_Reflect_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/CTR_value.text = "%s" % Player_Stats.Counter_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/HPR_value.text = "%s/s" % Player_Stats.Health_Regeneration_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/MPR_value.text = "%s/s" % Player_Stats.Mana_Regeneration_get()

func _on_AttributesTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $ScrollContainer/VBoxContainer/Teir1.visible:
				$ScrollContainer/VBoxContainer/Teir1.visible = false
				$ScrollContainer/VBoxContainer/HSeparator.visible = false
			else:
				$ScrollContainer/VBoxContainer/Teir1.visible = true
				$ScrollContainer/VBoxContainer/HSeparator.visible = true


func _on_CombatSkillsTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $ScrollContainer/VBoxContainer/Teir2.visible:
				$ScrollContainer/VBoxContainer/Teir2.visible = false
				$ScrollContainer/VBoxContainer/HSeparator2.visible = false
			else:
				$ScrollContainer/VBoxContainer/Teir2.visible = true
				$ScrollContainer/VBoxContainer/HSeparator2.visible = true


func _on_SecondarySkillsTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $ScrollContainer/VBoxContainer/Teir3.visible:
				$ScrollContainer/VBoxContainer/Teir3.visible = false
				$ScrollContainer/VBoxContainer/HSeparator3.visible = false
			else:
				$ScrollContainer/VBoxContainer/Teir3.visible = true
				$ScrollContainer/VBoxContainer/HSeparator3.visible = true


func _on_StatusTitle_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if $ScrollContainer/VBoxContainer/Teir4.visible:
				$ScrollContainer/VBoxContainer/Teir4.visible = false
				$ScrollContainer/VBoxContainer/HSeparator4.visible = false
			else:
				$ScrollContainer/VBoxContainer/Teir4.visible = true
				$ScrollContainer/VBoxContainer/HSeparator4.visible = true
