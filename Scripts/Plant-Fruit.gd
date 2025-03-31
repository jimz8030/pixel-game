extends Node
#drag and drop fruit that you want the plant to provide
@export var fruit_file_path : String
var fruit_item : Node2D
@onready var regrow_timer : Timer = $"Regrow Time"

#used to run a process if-statement once
var ran_once = false


func _ready() -> void:
	fruit_item = load(fruit_file_path).instantiate()
	add_child(fruit_item)
	fruit_item.position = Vector2 (11, -27)
	fruit_item.freeze = true


func _process(_delta) -> void:
	if fruit_item.position != Vector2 (11, -27) and !ran_once:
		regrow_timer.start()
		fruit_item = load(fruit_file_path).instantiate()
		ran_once = true
	elif fruit_item.position == Vector2 (11, -27):
		regrow_timer.stop()


#REGROW FRUIT
func _on_regrow_time_timeout() -> void:
	add_child(fruit_item)
	fruit_item.position = Vector2 (11, -27)
	fruit_item.freeze = true
	ran_once = false
