class_name cosmetic
extends Resource

@export var Number_of_Sprites : int = 1
var Texur_Repeat : int = 1

'''
for n in range(0,Number_of_Sprites)
	@export var H(Texur_Repeat) : Texture2D
	Texur_Repeat += 1
'''

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
