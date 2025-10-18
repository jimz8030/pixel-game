extends Node

@onready var player = $PlayerBody
var skin_color : Color

func _ready() -> void:
	#provides initial customization when there are no options selected
	if CosmeticManager.skin == Color(0, 0, 0, 1):
		#Set Hair, skin color, etc
		player.get_child(3).get_child(1).frame = 0
		skin_color = Color(0.33, 0.2, 0.13, 1)
		player.get_child(3).get_child(0).set_modulate(skin_color)
		player.get_child(3).get_child(3).visible = true
		player.get_child(3).get_child(2).visible = true
	#Uses old customization when they are already chosen
	else:
		player.get_child(3).get_child(1).frame = CosmeticManager.hair_type
		player.get_child(3).get_child(2).visible = CosmeticManager.bottom_clothing
		player.get_child(3).get_child(3).visible = CosmeticManager.top_clothing
		$SKIN.value = CosmeticManager.skin.g * 100

func _process(_float) -> void:
	#Makes sure the player doesn't go anywhere
	if player != null:
		player.position = Vector2(520, 180)
		player.get_child(2).scale.x = 1
		player.get_child(10).visible = false

#HAIR
func _on_head_pressed() -> void:
	#changes the hair sprite in player appearance
	player.get_child(2).get_child(1).frame += 1
	if player.get_child(2).get_child(1).frame == 20:
		player.get_child(2).get_child(1).frame = 0

#TOP CLOTHING
func _on_top_pressed() -> void:
	if player.get_child(3).get_child(3).visible == true:
		player.get_child(3).get_child(3).visible = false
	else:
		player.get_child(3).get_child(3).visible = true

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

#START GAME
func _on_apply_pressed() -> void:
	CosmeticManager.hair_type = player.get_child(3).get_child(1).frame
	CosmeticManager.bottom_clothing = player.get_child(3).get_child(2).visible
	CosmeticManager.top_clothing = player.get_child(3).get_child(3).visible
	CosmeticManager.skin = skin_color
	get_tree().change_scene_to_file("res://Scenes/Control_Tutorial.tscn")


func _on_head_back_pressed() -> void:
	player.get_child(3).get_child(1).frame -= 1
	if player.get_child(3).get_child(1).frame == 0:
		player.get_child(3).get_child(1).frame = 19


func _on_head_next_pressed() -> void:
	player.get_child(3).get_child(1).frame += 1
	if player.get_child(3).get_child(1).frame == 20:
		player.get_child(3).get_child(1).frame = 0
