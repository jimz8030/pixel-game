extends Node

@onready var player = $PlayerBody
var skin_color : Color
@export var top_clothing : Array[CompressedTexture2D]
@export var bottoms_unlocked : Array[CompressedTexture2D]

func _ready() -> void:
	$AnimationPlayer.play("Face")
	#Since global variable cannot be accessed, I use a variable here and apply it to the global
	Global_Variables.top_clothing = top_clothing

	#provides initial customization when there are no options selected
	if Global_Variables.skin == Color(0, 0, 0, 1):
		#Set Hair, skin color, etc
		player.get_child(3).get_child(1).frame = 0
		skin_color = Color(0.33, 0.2, 0.13, 1)
		player.get_child(3).get_child(0).set_modulate(skin_color)
		player.get_child(3).get_child(3).visible = true
		player.get_child(3).get_child(2).visible = true
	#Uses old customization when they are already chosen
	else:
		player.get_child(3).get_child(1).frame = Global_Variables.hair_type
		player.get_child(3).get_child(2).visible = Global_Variables.bottom_clothing
		$"PlayerBody/Appearance/Top_Clothing".texture = load(Global_Variables.top_clothing[Global_Variables.selected_top].load_path)
		$SKIN.value = Global_Variables.skin.g * 100

func _process(_float) -> void:
	#Makes sure the player doesn't go anywhere
	if player != null:
		player.position = Vector2(129, 180)
		player.get_child(2).scale.x = 1
		player.get_child(11).visible = false
		player.get_child(1).visible = false

#BOTTOM CLOTHING
func _on_bottom_pressed() -> void:
	if player.get_child(3).get_child(2).visible == true:
		player.get_child(3).get_child(2).visible = false
	else:
		player.get_child(3).get_child(2).visible = true

#SKIN
func _on_skin_value_changed(value: float) -> void:
	skin_color = Color($SKIN.value/60, $SKIN.value/100, $SKIN.value/150, 1)
	player.get_child(3).get_child(0).set_modulate(skin_color)

#HAIR
func _on_head_back_pressed() -> void:
	player.get_child(3).get_child(1).frame -= 1
	if player.get_child(3).get_child(1).frame == 0:
		player.get_child(3).get_child(1).frame = 23
func _on_head_next_pressed() -> void:
	player.get_child(3).get_child(1).frame += 1
	if player.get_child(3).get_child(1).frame == 23:
		player.get_child(3).get_child(1).frame = 0

#TOP
func _on_top_next_pressed() -> void:
	if (Global_Variables.selected_top + 2) > Global_Variables.top_clothing.size():
		Global_Variables.selected_top = 0
	else:
		Global_Variables.selected_top += 1
	$"PlayerBody/Appearance/Top_Clothing".texture = load(Global_Variables.top_clothing[Global_Variables.selected_top].load_path)
func _on_top_back_pressed() -> void:
	if (Global_Variables.selected_top - 1) < 0:
		Global_Variables.selected_top = Global_Variables.top_clothing.size() - 1
	else:
		Global_Variables.selected_top -= 1
	$"PlayerBody/Appearance/Top_Clothing".texture = load(Global_Variables.top_clothing[Global_Variables.selected_top].load_path)

#START GAME
func _on_apply_pressed() -> void:
	Global_Variables.hair_type = player.get_child(3).get_child(1).frame
	Global_Variables.bottom_clothing = player.get_child(3).get_child(2).visible
	Global_Variables.skin = skin_color
	get_tree().change_scene_to_file("res://Scenes/Ship.tscn")
