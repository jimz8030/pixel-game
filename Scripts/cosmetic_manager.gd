class_name cosmetic
extends CanvasLayer

#makes strings that will be used later to make script find specific sprite files
var Body_Skin_Name : String = "M1.S1.png"
var Hair_type : String = "H2.png"
var Top_Clothing : String = "T1.png"
var Bottom_Clothing : String = "Bott.1.png"

#
var Character_Body : Sprite2D
var Character_Hair : Sprite2D
var Character_Top : Sprite2D
var Character_Top_Arm : Sprite2D
var Character_Bottom : Sprite2D

var Hair_Exception_1 : Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Character_Body = $Character/Body/Body_Sprite
	Character_Hair = $Character/Hair/Hair_Sprite
	Character_Top = $Character/Top_Clothing/Top_Clothing_Sprite
	Character_Top_Arm = $Character/Top_Clothing/Arm
	Character_Bottom = $Character/Bottom_Clothing/Bottom_Clothing_Sprite
	Hair_Exception_1 = $Character/Top_Clothing/Hair_Beard

func _on_female_button_down() -> void:
	#change to female
	Body_Skin_Name[0] = "F"
	Change_Body()
	
func _on_male_button_down() -> void:
	Body_Skin_Name[0] = "M"
	Change_Body()
	
func _on_body_1_button_down() -> void:
	Body_Skin_Name[1] = "1"
	Change_Body()
	
func _on_body_2_button_down() -> void:
	Body_Skin_Name[1] = "2"
	Change_Body()

func _on_skin_slide_value_changed(value: float) -> void:
	Body_Skin_Name[4] = str(value + 1)
	Change_Body()

func _on_hair_slide_value_changed(value: float) -> void:
	Hair_type = "H" + str(value + 1) + ".png"
	Change_Body()

func _on_top_slide_value_changed(value: float) -> void:
	Top_Clothing = "T" + str(value + 1) + ".png"
	Change_Body()

func _on_bottom_slide_value_changed(value: float) -> void:
	Bottom_Clothing = "Bott." + str(value + 1) + ".png"
	Change_Body()

func Change_Body() -> void:
	Character_Body.texture = load("res://Sprites/Character_Sprites/Cosmetics/Oops_All_Naked/" + Body_Skin_Name)
	Character_Hair.texture = load("res://Sprites/Character_Sprites/Cosmetics/Hair/" + Hair_type)
	Character_Top.texture = load("res://Sprites/Character_Sprites/Cosmetics/Top_Clothing/" + Top_Clothing)
	Character_Bottom.texture = load("res://Sprites/Character_Sprites/Cosmetics/Bottom_Clothing/" + Bottom_Clothing)
	if Hair_type == "H4.png":
		Character_Hair.visible = false
		Hair_Exception_1.visible = true
		print("beard activated")
	else:
		Character_Hair.visible = true
		Hair_Exception_1.visible = false
		print("No Beard")
