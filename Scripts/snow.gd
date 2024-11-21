extends CPUParticles2D

@export var switch = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if switch == true:
		snowfall()
		switch = false

func snowfall():
	var weather : int = randi_range(0, 3)
	
	if weather == 1:
		self.emitting = false
	elif weather == 2:
		self.emitting = true
		self.amount = 80
		self.gravity = Vector2(0, 500)
		self.orbit_velocity_max = 0.2
		self.orbit_velocity_min = -0.2
		self.speed_scale = 0.1
	else:
		self.emitting = false
		await get_tree().create_timer(10.0).timeout
		self.emitting = true
		var flow_direction : int = randi_range(0, 1)
		self.amount = 300
		self.speed_scale = 0.4
		if flow_direction == 1:
			self.orbit_velocity_max = -0.5
			self.orbit_velocity_min = -0.5
		else:
			self.orbit_velocity_max = 0.5
			self.orbit_velocity_min = 0.5
	print ("Weather: " + str(weather))
