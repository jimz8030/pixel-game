using Godot;
using System;
using System.ComponentModel;
using System.Security.Cryptography.X509Certificates;


public partial class CharacterBody2d : CharacterBody2D
{
	
	InputEventKey interact_key = new InputEventKey();
	public const float Speed = 300.0f;
	public const float JumpVelocity = -400.0f;
	
	public override void _Ready()
	{
		//sets the key E to the interact inputmap (without using inputmap)
		interact_key.Keycode = Key.E;
		InputMap.AddAction("interact");
		InputMap.ActionAddEvent("interact", interact_key);
		
		//this gets the node player reach so they can interact with eachoter
		Godot.Node2D Player_reach = this.GetNode<Area2D>("PlayerReachArea");

	}


    public override void _Input(InputEvent @event)
    {
        base._Input(@event);
		if (Input.IsActionJustPressed("interact")) {
			GD.Print("interacted and ready to go");
		}
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
		if (Input.IsActionJustPressed("ui_accept") && IsOnFloor())
		{
			velocity.Y = JumpVelocity;
		}

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		Vector2 direction = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");

		if (direction != Vector2.Zero)
		{
			velocity.X = direction.X * Speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
		}
		
		if (Input.IsActionJustPressed("ui_right")){
			GetNode<Sprite2D>("Sprite2D").FlipH = true;
			GetNode<Area2D>("PlayerReachArea").Position = new Vector2(16,0);
		}
		if (Input.IsActionJustPressed("ui_left")){
			GetNode<Sprite2D>("Sprite2D").FlipH = false;
			GetNode<Area2D>("PlayerReachArea").Position = new Vector2(-16,0);

		}
		Velocity = velocity;
		MoveAndSlide();/*
		Vector2 direction = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");

		if (Input.IsActionJustPressed("ui_right"))
		{
			Scale = new Vector2(-1, 1);
		}

		else if (Input.IsActionJustPressed("ui_left"))
		{
			Scale = new Vector2(1, 1);
		}

		if (direction != Vector2.Zero)
		{
			velocity.X = direction.X * Speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
		}
		

		velocity.Y = gravity * (float)delta;
		Velocity = velocity;
		//MoveAndSlide();*/
		
	}
}
