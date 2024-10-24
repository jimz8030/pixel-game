using Godot;
using System;
using System.ComponentModel;
using System.Security.Cryptography.X509Certificates;


public partial class CharacterBody2d : CharacterBody2D
{
	Godot.Node2D PlayerReach;
	InputEventKey InteractKey = new InputEventKey();
	InputEventKey AttackKey = new InputEventKey();
	InputEventKey DashKey = new InputEventKey();
	
	public const float Speed = 300.0f;
	public const float JumpVelocity = -400.0f;
	public float DashCharging = 0f;
	


	public override void _Ready()
	{
		GD.PrintErr("problem when moving after jump dashing");
		//sets the key E to the interact inputmap (without using inputmap)
		InteractKey.Keycode = Key.E;
		InputMap.AddAction("interact");
		InputMap.ActionAddEvent("interact", InteractKey);
		AttackKey.Keycode = Key.R;
		InputMap.AddAction("attack");
		InputMap.ActionAddEvent("attack", AttackKey);
		DashKey.Keycode = Key.Shift;
		InputMap.AddAction("dash");
		InputMap.ActionAddEvent("dash", DashKey);

		//this gets the node player reach so they can interact with eachoter
		PlayerReach = this.GetNode<Area2D>("PlayerReachArea");

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
			GetNode<Area2D>("PlayerReachArea").Position = new Vector2(32,0);
		}
		else if (Input.IsActionJustPressed("ui_left")){
			GetNode<Sprite2D>("Sprite2D").FlipH = false;
			GetNode<Area2D>("PlayerReachArea").Position = new Vector2(0,0);

		}
		Velocity = velocity;
		MoveAndSlide();
		
	}
}
