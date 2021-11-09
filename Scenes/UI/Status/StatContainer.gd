extends Control


var Player_Stats_node

func _ready():
	Player_Stats_node = get_player_stats()
	refresh_stats()
	Player_Stats_node.connect("Stat_value_changed", self, "_Stat_value_changed")
	Player_Stats_node.connect("Health_changed", self, "_HPMP_value_changed")
	Player_Stats_node.connect("Mana_changed", self, "_HPMP_value_changed")


func get_player_stats():
	#Needs to be updated
	return get_parent().get_parent().get_parent().get_node_or_null("Stats")

func _Stat_value_changed(_stat, _value):
	refresh_stats()

func _HPMP_value_changed(_value):
	refresh_stats()

func refresh_stats():
	if Player_Stats_node == null:
		Logger.error("No Player_Stats_node was loaded to StatContainer")
	else:
		#Teir 0
		$ScrollContainer/VBoxContainer/Teir1/Values/HP_value.text = "%s/%s" % [Player_Stats_node.Current_Health_get(), Player_Stats_node.Max_Health_get()]
		$ScrollContainer/VBoxContainer/Teir1/Values/MP_value.text = "%s/%s" % [Player_Stats_node.Current_Mana_get(), Player_Stats_node.Max_Mana_get()]
		#Teir 1
		$ScrollContainer/VBoxContainer/Teir1/Values/STR_value.text = "%s" % Player_Stats_node.Strength_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/VIT_value.text = "%s" % Player_Stats_node.Vitality_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/WIS_value.text = "%s" % Player_Stats_node.Wisdom_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/WIL_value.text = "%s" % Player_Stats_node.Willpower_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/DEX_value.text = "%s" % Player_Stats_node.Dexterity_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/AGI_value.text = "%s" % Player_Stats_node.Agility_get()
		$ScrollContainer/VBoxContainer/Teir1/Values/LUK_value.text = "%s" % Player_Stats_node.Luck_get()
		#Teir 2
		$ScrollContainer/VBoxContainer/Teir2/Values/ATK_value.text = "%s" % Player_Stats_node.Attack_get()
		$ScrollContainer/VBoxContainer/Teir2/Values/DEF_value.text = "%s" % Player_Stats_node.Defense_get()
		$ScrollContainer/VBoxContainer/Teir2/Values/MAT_value.text = "%s" % Player_Stats_node.Magic_Attack_get()
		$ScrollContainer/VBoxContainer/Teir2/Values/MDF_value.text = "%s" % Player_Stats_node.Magic_Defense_get()
		$ScrollContainer/VBoxContainer/Teir2/Values/APS_value.text = "%s" % Player_Stats_node.Attack_Speed_get()
		#Teir 3
		$ScrollContainer/VBoxContainer/Teir3/Values/HIT_value.text = "%s" % Player_Stats_node.Hit_Chance_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/EVA_value.text = "%s" % Player_Stats_node.Evasion_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/CRT_value.text = "%s" % Player_Stats_node.Critical_Chance_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/CRM_value.text = "%s" % Player_Stats_node.Critical_Multiplier_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/CRE_value.text = "%s" % Player_Stats_node.Critical_Evade_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/MEV_value.text = "%s" % Player_Stats_node.Magic_Evade_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/MGR_value.text = "%s" % Player_Stats_node.Magic_Reflect_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/CTR_value.text = "%s" % Player_Stats_node.Counter_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/HPR_value.text = "%s/s" % Player_Stats_node.Health_Regeneration_get()
		$ScrollContainer/VBoxContainer/Teir3/Values/MPR_value.text = "%s/s" % Player_Stats_node.Mana_Regeneration_get()

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
