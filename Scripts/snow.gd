extends CPUParticles2D

#Used to determine intensity of weather
var weather : int = 1
var stepParticles : CPUParticles2D
var character : CharacterBody2D

#sets initial weather
func _ready() -> void:
	stepParticles = $"../../CharacterBody2D/Step_Particles"
	character = $"../../CharacterBody2D"
	self.emitting = true
	snowfall()

func _process(_delta: float) -> void:
	if character.is_on_floor() and character.velocity != Vector2(0, 0):
		stepParticles.emitting = true

#Used to determine when weather will change
func _on_weather_wait_timeout() -> void:
	snowfall()
	print("WEATHER CHANGED")

func snowfall():
	weather = randi_range(0, 20)
	
	if weather <= 5:
		self.emitting = false
	elif weather <= 19 and weather >= 6:
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
