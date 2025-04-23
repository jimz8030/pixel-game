extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.get_child(0).node_b != body.get_path():
		print (body.get_child(0).node_b)
		if body.mass > 12:
			$"../Terrapus".player_opinion += 2.4
		else:
			$"../Terrapus".player_opinion += 0.2


func _on_body_exited(body: Node2D) -> void:
	if body.mass > 12:
		$"../Terrapus".player_opinion -= 3
	else:
		$"../Terrapus".player_opinion -= 0.2
