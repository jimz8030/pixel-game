extends Control

@onready var Inv : inv = preload("res://Resources/Inventory/playerInventory.tres")
@onready var slots : Array = $GridContainer.get_children()

func _ready():
	update_slots()

func update_slots():
	for i in range(min(Inv.items.size(), slots.size())):
		slots[i].update(Inv.items[i])
