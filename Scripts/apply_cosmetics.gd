extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	var Character_Hair : Sprite2D = $Hair/Hair_Sprite
	
	$Body/Body_Sprite.texture = load(Globals.Character_Body)
	$Bottom_Clothing/Bottom_Clothing_Sprite.texture = load(Globals.Character_Bottom)
	Character_Hair.texture = load(Globals.Character_Hair)
	$Top_Clothing/Top_Clothing_Sprite.texture = load(Globals.Character_Top)
	$Arm/Skin_Arm.texture = load(Globals.Character_Flesh_Arm)
	$Arm/Clothing_Sprite.texture = load(Globals.Character_Cloth_Arm)
	
	if Character_Hair.texture != null:
		if Character_Hair.texture.resource_path == "res://Sprites/Character_Sprites/Hair/H4.png" or Character_Hair.texture.resource_path == "res://Sprites/Character_Sprites/Hair/H13.png":
			if $Hair.has_node("/root/Node2D/CanvasLayer/Character/Hair/Hair_Sprite"):
				var hair_sprite = $Hair/Hair_Sprite
				$Hair.remove_child($Hair/Hair_Sprite)
				$Top_Clothing.add_child(hair_sprite)
		else:
			if $Top_Clothing.has_node("/root/Node2D/CanvasLayer/Character/Top_Clothing/Hair_Sprite"):
				var hair_sprite = $Top_Clothing/Hair_Sprite
				$Top_Clothing.remove_child($Top_Clothing/Hair_Sprite)
				$Hair.add_child(hair_sprite)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
