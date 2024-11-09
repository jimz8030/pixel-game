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
	public float JumpVelocity;
	public float Gravity;
	public float DashCharging = 0f;
	public float MaxCoyoteJumpTime = 1f;
	public float CurrentCoyoteJumpTime;
	float FramePerfectJump;
	float AttackCharging;
	float JumpCharging = 0;
	
	//jumpheight is the hight you want the player to jump at
	const int JumpHeight = 60;
	//Time in air doubled is the ammount of time the jump takes before touching ground
	const float TimeInAir = 0.5f;

	public Node2D PlayerSprite;
	


	private void SetVariables()
	{
		Gravity = JumpHeight/(float)Math.Pow(TimeInAir/2, 2);
		GD.Print(Gravity);
		JumpVelocity = -TimeInAir * Gravity;
	}
	public override void _Ready()
	{
		SetVariables();
		MainNode = GetParent<Node2D>();
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
		
		PlayerSprite = GetNode<Node2D>("Character");

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
			CurrentCoyoteJumpTime -= .1f;
			if (velocity.Y <= 1000){
				velocity.Y += Gravity * (float)delta;
				// velocity += GetGravity() * (float)delta; // change this equation to use math, so we can change the max jump height and time in the air easier
			}
		}
		else{
			CurrentCoyoteJumpTime = MaxCoyoteJumpTime;
			if (JumpCharging > 0){
				JumpCharging -= .1f;
			}
		}

		// Handle Jump.
		if (FramePerfectJump > 0){
			FramePerfectJump -= .1f;
		}
		if (Input.IsActionJustPressed("ui_accept"))
		{
			if (CurrentCoyoteJumpTime > 0 && DashCharging <= 9.5f && JumpCharging <= 0){
				velocity.Y = JumpVelocity;
				GD.Print(velocity.Y);
				GD.Print(JumpVelocity);
				GD.Print(velocity.Y);
				JumpCharging = 1f;
				}
			else if (!IsOnFloor()){
				FramePerfectJump = 1f;
			}
		}
		if (FramePerfectJump > 0 && IsOnFloor()){
				velocity.Y = JumpVelocity;
				JumpCharging = 1f;
			}

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		Vector2 direction = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
		if (direction != Vector2.Zero && DashCharging <= 9f)
		{
			//checks if velocity is greater than how fast the player would walk
			if (Math.Abs(velocity.X) > Math.Abs(direction.X * Speed) && IsOnFloor() == false){
				//this checks if the player wants to move in the other direction
				if (Math.Sign(direction.X) != Math.Sign(velocity.X)){
					velocity.X = direction.X * Speed;
				}
				else{
					velocity.X = Mathf.MoveToward(velocity.X, 0, 10);
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
			//sets velocity to 0 so dash doesnt add to walk speed
			velocity.X = 0;
			if (IsOnFloor() && Input.IsActionPressed("ui_accept") == false){
				SpeedModifier = 10f;
			}
			if (PlayerSprite.Scale.X < 0){
				velocity.X += Speed * SpeedModifier;
			}
			else{
				velocity.X -= Speed * SpeedModifier;
			}
		}

		if (Input.IsActionJustPressed("ui_right")){
			//these two if statements flip the area2d called player reach. the reason Vector2 is 32 and 0 is because it changes based on it's starting position. basically it's changing the position by 32 pixels to the right and it goes back to starting position if you're facing the left
			PlayerSprite.Scale = new Vector2(-1, 1);
			PlayerReach.Position = new Vector2(16,0);
		}
		else if (Input.IsActionJustPressed("ui_left")){
			PlayerSprite.Scale = new Vector2(1, 1);
			PlayerReach.Position = new Vector2(-16,0);

		}
		Velocity = velocity;
		MoveAndSlide();
		
	}
}
