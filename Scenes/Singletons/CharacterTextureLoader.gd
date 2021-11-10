extends Node

var character1 = {
	"p1_base":"res://Assets/Character/Base character/char_a_p1/char_a_p1_0bas_humn_v01.png",
	"p1_hair":"res://Assets/Character/Base character/char_a_p1/4har/char_a_p1_4har_bob1_v01.png",
	"p1_outfit":"res://Assets/Character/Base character/char_a_p1/1out/char_a_p1_1out_boxr_v01.png",
	"p2_base":"res://Assets/Character/Base character/char_a_p2/char_a_p2_0bas_humn_v01.png",
	"p2_hair":"res://Assets/Character/Base character/char_a_p2/4har/char_a_p2_4har_bob1_v01.png",
	"p2_outfit":"res://Assets/Character/Base character/char_a_p2/1out/char_a_p2_1out_boxr_v01.png",
	"tool":"res://Assets/Character/Base character/char_a_p2/6tla/char_a_p2_6tla_wood_v01.png"
}

var character1_textures : Dictionary

func _ready():
	for key in character1:
		character1_textures[key] = load(character1[key])
