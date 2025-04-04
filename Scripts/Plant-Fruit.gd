extends Node

#drag and drop fruit that you want the plant to provide
@export var fruit_file_path : String
#used to get a fruit from the game files (using the file path)
var fruit_item : Node2D


#CHECK IF FRUIT IS REMOVED
func _process(_delta) -> void:
	
	#new fruit prepares to grow
	if fruit_item != null:
		if fruit_item.position != Vector2 (11, -27):
			$"Regrow Time".start()
			fruit_item = null


#REGROW FRUIT
func _on_regrow_time_timeout() -> void:

	# Grow a new fruit
	fruit_item = load(fruit_file_path).instantiate()
	#if it's time to grow a new fruit, we add the fruit we got from the files to the plant
	add_child(fruit_item)
	#we position the fruit
	fruit_item.position = Vector2 (11, -27)
	#we freeze the fruit's physics so it stays still
	fruit_item.freeze = true
	#timer stops itself
	$"Regrow Time".stop()
	$"Drop Time".start()
	


#DROP FRUIT
func _on_drop_time_timeout() -> void:
	if get_child(4) != null:
		fruit_item = get_child(4)
		fruit_item.freeze = false
		$"Drop Time".stop()
