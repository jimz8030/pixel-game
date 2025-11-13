extends Node2D

var next_to_console

func _ready() -> void:
	$AnimationPlayer.play("Idle")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Store"):
		if next_to_console:
			$PlayerBody.visible = false
			$PlayerBody/Camera.reparent($"Clone Console")
			$AnimationPlayer.play("Sunil Runs")

func _on_clone_console_body_entered(body: Node2D) -> void:
	if body.collision_layer == 2:
		$"Clone Console/Label".visible = true
		next_to_console = true


func _on_clone_console_body_exited(body: Node2D) -> void:
	if body.collision_layer == 2:
		$"Clone Console/Label".visible = false
		next_to_console = false

func delete_Sunil():
	$PlayerBody.queue_free()
	
func end_of_scene():
	$Clone.can_control = true
	$"Clone Console/Camera".reparent($Clone)
