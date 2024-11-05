class_name cosmetic
extends CanvasLayer

#makes strings that will be used later to make script find specific sprite files
var Body_Skin_Name : String = "F1.S1.png"
var Hair_type : String = "H2.png"
var Bottom_Clothing : String = "Bott.1.png"
var Top_Clothing : String = "T1_F1.png"

var T_C_3 : String = "F"
var T_C_4 : String = "1"
var T_Count : String = "1"

var Clothing_Arm : String = "A1.png"
var Flesh_Arm : String = "F1.png"

#These strings will be assigned parts of the player later
var Character_Body : Sprite2D
var Character_Hair : Sprite2D
var Character_Bottom : Sprite2D
var Character_Top : Sprite2D

var Character_Cloth_Arm : Sprite2D
var Character_Flesh_Arm : Sprite2D

#These are hair types that need to be in front of clothes (usually beards)
@export var Hair_Exception_1 : String
@export var Hair_Exception_2 : String

var Hair_Excp_1 : Sprite2D
var Hair_Excp_2 : Sprite2D

#Gets the next scene after character creator
@export var Next_Scene = preload("res://Scenes/Tutorial.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Gets character sprites to change later
	Character_Body = $Character/Body/Body_Sprite
	Character_Hair = $Character/Hair/Hair_Sprite
	Character_Top = $Character/Top_Clothing/Top_Clothing_Sprite
	Character_Bottom = $Character/Bottom_Clothing/Bottom_Clothing_Sprite
	
	Hair_Excp_1 = $Character/Top_Clothing/Hair_Beard
	Hair_Excp_2 = $Character/Top_Clothing/Hair_Beard_2

	Character_Cloth_Arm = $Character/Arm/Clothing_Sprite
	Character_Flesh_Arm = $Character/Arm/Skin_Arm

#determines what sprite to get when button is pressed
func _on_female_button_down() -> void:
	#change to female
	Body_Skin_Name[0] = "F"
	Change_Body()

#determines what sprite to get when button is pressed
func _on_male_button_down() -> void:
	Body_Skin_Name[0] = "M"
	Change_Body()

#determines what sprite to get when button is pressed
func _on_body_1_button_down() -> void:
	Body_Skin_Name[1] = "1"
	Change_Body()

#determines what sprite to get when button is pressed
func _on_body_2_button_down() -> void:
	Body_Skin_Name[1] = "2"
	Change_Body()

#determines what sprite to get when slider is interacted with
func _on_skin_slide_value_changed(value: float) -> void:
	Body_Skin_Name[4] = str(value + 1)
	Flesh_Arm[1] = str(value + 1) + ".png"
	Change_Body()

#determines what sprite to get when slider is interacted with
func _on_hair_slide_value_changed(value: float) -> void:
	Hair_type = "H" + str(value + 1) + ".png"
	Change_Body()

#determines what sprite to get when slider is interacted with
func _on_top_slide_value_changed(value: float) -> void:
	#Top clothing needs to be defined in the change body function.
	T_Count = str(value + 1)
	Clothing_Arm = "A" + str(value + 1) + ".png"
	Change_Body()

#determines what sprite to get when slider is interacted with
func _on_bottom_slide_value_changed(value: float) -> void:
	Bottom_Clothing = "Bott." + str(value + 1) + ".png"
	Change_Body()

#Applies changes to character
func Change_Body() -> void:
	#Change the characters of the top clothing file name to match the last two digits of the body shape
	#This way the clothing can match the body shape.
	Top_Clothing = "T" + T_Count + "_" + Body_Skin_Name[0] + Body_Skin_Name[1] + ".png"
	
	Character_Body.texture = load("res://Sprites/Character_Sprites/Oops_All_Naked/" + Body_Skin_Name)
	Character_Hair.texture = load("res://Sprites/Character_Sprites/Hair/" + Hair_type)
	Character_Bottom.texture = load("res://Sprites/Character_Sprites/Bottom_Clothing/" + Bottom_Clothing)
	Character_Top.texture = load("res://Sprites/Character_Sprites/Top_Clothing/" + Top_Clothing)
	
	Character_Cloth_Arm.texture = load("res://Sprites/Character_Sprites/Top_Clothing/Clothing_Arms/" + Clothing_Arm)
	Character_Flesh_Arm.texture = load("res://Sprites/Character_Sprites/Oops_All_Naked/Flesh_Arms/" + Flesh_Arm)

	#Changes sprites that are displayed when they are exceptions
	if Hair_type == Hair_Exception_1:
		Character_Hair.visible = false
		Hair_Excp_2.visible = false
		Hair_Excp_1.visible = true
	elif Hair_type == Hair_Exception_2:
		Character_Hair.visible = false
		Hair_Excp_1.visible = false
		Hair_Excp_2.visible = true
	else:
		Character_Hair.visible = true
		Hair_Excp_1.visible = false
		Hair_Excp_2.visible = false

#Plays next scene after character creator when button is pressed
func _on_next_scene_button_down() -> void:
	get_tree().change_scene_to_packed(Next_Scene)
