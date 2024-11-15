extends CPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_up"):
		self.amount += 60
		self.speed_scale += 0.03
		print (self.amount)
	
	if Input.is_action_just_pressed("ui_down"):
		self.amount -= 60
		self.speed_scale -= 0.03
		print (self.amount)
		
	if self.amount >= 300:
		self.gravity = Vector2(-500, 200)
		self.position = Vector2(250, -300)
	else:
		self.position = Vector2(0, -300)
		self.gravity = Vector2(0, 980)
