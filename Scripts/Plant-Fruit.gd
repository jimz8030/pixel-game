extends Node

#plant grows fruit
#plant drops the fruit, but it still remembers the fruit until the fruit is either gone or the player picks it up.
#plant does not grow a new fruit until the fruit is either gone or has been interacted by the player.


#drag and drop fruit that you want the plant to provide
@export var fruit_file_path : String
#used to get a fruit from the game files (using the file path)
var fruit_item : Node2D

var grow_times : Array = [10, 20, 60]

func _ready() -> void:
	fruit_item = $Cotton
	$"Drop Time".start()

#CHECK IF FRUIT IS REMOVED
func _process(_delta) -> void:
	
	if fruit_item != null:
		if fruit_item.position.x != 11:
			$"Regrow Time".wait_time = choose(grow_times)
			$"Regrow Time".start()
			fruit_item = null

#REGROW FRUIT
func _on_regrow_time_timeout() -> void:

	# Grow a new fruit
	fruit_item = load(fruit_file_path).instantiate()
	#if it's time to grow a new fruit, we add the fruit we got from the files to the plant
	add_child(fruit_item)
	#we freeze the fruit's physics so it stays still
	fruit_item.freeze = true
	#we position the fruit
	fruit_item.position = Vector2 (11, -27)
	#timer stops itself
	$"Regrow Time".stop()
	$"Drop Time".start()

#DROP FRUIT
func _on_drop_time_timeout() -> void:
	if get_children().size() == 5:
		fruit_item = get_child(4)
		fruit_item.get_child(0).set_node_b(fruit_item.get_path())
		fruit_item.freeze = false
		$"Drop Time".stop()

func choose(array):
	array.shuffle()
	return array.front()
