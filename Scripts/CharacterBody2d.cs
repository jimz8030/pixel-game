using Godot;
using System;
using System.ComponentModel;
using System.Security.Cryptography.X509Certificates;

//this node is meant to get everything set up for its children and handle movement for the player. This means setting up controls and processing movement (also sometimes transfering data between nodes)
public partial class CharacterBody2d : CharacterBody2D
{
	public Godot.Node2D MainNode;
	Godot.Area2D PlayerReach;
	InputEventKey InteractKey = new InputEventKey();
	InputEventMouseButton AttackKey = new InputEventMouseButton();
	InputEventKey DashKey = new InputEventKey();
	InputEventKey RightKey = new InputEventKey(); 
	InputEventKey LeftKey = new InputEventKey();
	InputEventKey JumpKey = new InputEventKey();
	InputEventKey DownKey = new InputEventKey();
	
	public const float Speed = 300.0f;
	public const float JumpVelocity = -400.0f;
	public float DashCharging = 0f;
	float AttackCharging;
	


	public override void _Ready()
	{
		MainNode = GetParent<Node2D>();
		GD.PrintErr("problem when moving after jump dashing");
		//sets the key E to the interact inputmap (without using inputmap)
		InteractKey.Keycode = Key.E;
		InputMap.AddAction("interact");
		InputMap.ActionAddEvent("interact", InteractKey);
		AttackKey.ButtonIndex = MouseButton.Right;
		InputMap.AddAction("attack");
		InputMap.ActionAddEvent("attack", AttackKey);
		DashKey.Keycode = Key.Shift;
		InputMap.AddAction("dash");
		InputMap.ActionAddEvent("dash", DashKey);

		//WARNING using "ui_right" instead of "move_right" or another word is poor coding
		RightKey.Keycode = Key.D;
		//InputMap.AddAction("")
		InputMap.ActionAddEvent("ui_right", RightKey);
		LeftKey.Keycode = Key.A;
		InputMap.ActionAddEvent("ui_left", LeftKey);
		JumpKey.Keycode = Key.W;
		InputMap.ActionAddEvent("ui_accept", JumpKey);
		DownKey.Keycode = Key.S;
		InputMap.ActionAddEvent("ui_down", DownKey);

		//this gets the node player reach so they can interact with eachoter
		PlayerReach = GetNode<Area2D>("PlayerReachArea");

	}


    public override void _Input(InputEvent @event)
    {
        base._Input(@event);
		//not important because Player_reach_area is handling the inputs (I would do things here, but the variables don't transfer well)
	}


    public override void _PhysicsProcess(double delta)
	{
		Vector2 velocity = Velocity;
		//float gravity = 10.0f;
		//float speed = 3.0f;
		// Add the gravity.
		if (!IsOnFloor())
		{
			velocity += GetGravity() * (float)delta;
		}

		// Handle Jump.
		if (Input.IsActionJustPressed("ui_accept") && IsOnFloor() && DashCharging <= 9.5f)
		{
			velocity.Y = JumpVelocity;
		}

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		Vector2 direction = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
		if (direction != Vector2.Zero && DashCharging <= 9f)
		{
			if (Math.Abs(velocity.X) > Math.Abs(direction.X * Speed) && IsOnFloor() == false){
				if (Math.Sign(direction.X) != Math.Sign(velocity.X)){
					velocity.X = direction.X * Speed;
				}
			}
			else{
			velocity.X = direction.X * Speed;

			}
		}
		else
		{
			if (IsOnFloor()){
				velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
			}
			else{
				velocity.X = Mathf.MoveToward(velocity.X, 0, 10);
			}
		}
		
		DashCharging -= 0.1f;
		if (Input.IsActionJustPressed("dash") && DashCharging <= 0f){
			DashCharging = 10f;
			float SpeedModifier = 3f;
			if (IsOnFloor() && Input.IsActionPressed("ui_accept") == false){
				SpeedModifier = 10f;
			}
			if (GetNode<Sprite2D>("Sprite2D").FlipH){
				velocity.X += Speed * SpeedModifier;
			}
			else{
				velocity.X -= Speed * SpeedModifier;
			}
			GD.Print("velocity of player is... "+velocity.X);
			GD.Print("dash activating... because ");
		}

		if (Input.IsActionJustPressed("ui_right")){
			//these two if statements flip the area2d called player reach. the reason Vector2 is 32 and 0 is because it changes based on it's starting position. basically it's changing the position by 32 pixels to the right and it goes back to starting position if you're facing the left
			GetNode<Sprite2D>("Sprite2D").FlipH = true;
			PlayerReach.Position = new Vector2(16,0);
		}
		else if (Input.IsActionJustPressed("ui_left")){
			GetNode<Sprite2D>("Sprite2D").FlipH = false;
			PlayerReach.Position = new Vector2(-16,0);

		}
		Velocity = velocity;
		MoveAndSlide();
		
	}
}
