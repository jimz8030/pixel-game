using Godot;
using System;
using System.ComponentModel;
using System.Security.Cryptography.X509Certificates;

//this node is meant to get everything set up for its children and handle movement for the player. This means setting up controls and processing movement (also sometimes transfering data between nodes)
public partial class CharacterBody2d : CharacterBody2D
{
	public Godot.Node2D MainNode;
	Godot.Area2D PlayerReach;

	InputEventMouseButton AttackKey = new InputEventMouseButton();
	InputEventMouseButton SecondaryKey = new InputEventMouseButton();
	InputEventKey InteractKey = new InputEventKey();
	InputEventKey DashKey = new InputEventKey();
	InputEventKey RightKey = new InputEventKey(); 
	InputEventKey LeftKey = new InputEventKey();
	InputEventKey JumpKey = new InputEventKey();
	InputEventKey DownKey = new InputEventKey();
	
	public const float Speed = 200.0f;
	public float JumpVelocity;
	public float Gravity;
	public float DashCharging = 0f;
	public float MaxCoyoteJumpTime = 1f;
	public float CurrentCoyoteJumpTime;
	float FramePerfectJump;
	float AttackCharging;
	float JumpCharging = .25f;
	
	//jumpheight is the hight you want the player to jump at
	const int JumpHeight = 30;
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
		AttackKey.ButtonIndex = MouseButton.Left;
		InputMap.AddAction("attack");
		InputMap.ActionAddEvent("attack", AttackKey);
		SecondaryKey.ButtonIndex = MouseButton.Right;
		InputMap.AddAction("special");
		InputMap.ActionAddEvent("special", SecondaryKey);

		//sets the key E to the interact inputmap (without using inputmap)
		InteractKey.Keycode = Key.E;
		InputMap.AddAction("interact");
		InputMap.ActionAddEvent("interact", InteractKey);
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
		InputMap.AddAction("crouch");
		InputMap.ActionAddEvent("crouch", DownKey);

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
			CurrentCoyoteJumpTime -= .125f;
			if (velocity.Y <= 1000){
				velocity.Y += Gravity * (float)delta;
				// velocity += GetGravity() * (float)delta; // change this equation to use math, so we can change the max jump height and time in the air easier
			}
		}
		else{
			CurrentCoyoteJumpTime = MaxCoyoteJumpTime;
		}

		// Handle Jump.
		// decreases Jump charging so the player can't jump twice or more before leaving the ground
		if (JumpCharging > 0){
			JumpCharging -= .125f;
		}
		// if frame perfect jump isn't 0 it slowly decreses (so it doesn't stay on)
		if (FramePerfectJump > 0){
			FramePerfectJump -= .125f;
		}
		// checks if someone pushes the space bar or enter
		if (Input.IsActionJustPressed("ui_accept"))
		{
			// If Youre on ground or just recently left the ground (as shown with coyote time) and you didn't just dash. (jump charging is just so the player doesn't press space too fast)
			if (CurrentCoyoteJumpTime > 0 && DashCharging <= 9.5f && JumpCharging <= 0){
				// makes you go up by setting upward velocity
				velocity.Y = JumpVelocity;
				// makes sure you can't jump again for 2 frames
				JumpCharging = .25f;
				}
			// if you're not on the ground and you tell the program to jump it will understand and let you jump when you touch the ground (8 frame window I think)
			else if (!IsOnFloor()){
				// sets the ammount of frames the frame perfect jump will last (also how forgiving) WARNING If this is set too high player might jump twice before stopping (also if theres something above the player the player will jump multiple times)
				FramePerfectJump = 1f;
			}
		}

		// this makes you jump with the frame perfect jump variable (incase they pressed jump button slightly too soon)
		if (FramePerfectJump > 0 && IsOnFloor()){
				velocity.Y = JumpVelocity;
				JumpCharging = .25f;
			}

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		Vector2 direction = Input.GetVector("ui_left", "ui_right", "ui_up", "crouch");
		// if thier movement is not 0 (they're moving), also checks if they recently dashed, in this case they shouldn't be able to move while dashing probably
		if (Input.IsActionPressed("ui_left") && !Input.IsActionPressed("ui_right")){
			direction.X = -1;
		}
		else if (Input.IsActionPressed("ui_right") && !Input.IsActionPressed("ui_left")){
			direction.X = 1;
		}
		if (direction != Vector2.Zero && DashCharging <= 9f)
		{
			//checks if velocity is greater than how fast the player would walk
			if (Math.Abs(velocity.X) > Math.Abs(direction.X * Speed) && IsOnFloor() == false){
				//this checks if the player wants to move in the other direction
				if (Math.Sign(direction.X) != Math.Sign(velocity.X)){
					// if they want to move in other direction then it changes thier speed to walking speed
					velocity.X = direction.X * Speed;
				}
				// if they don't want to change directions then they will still slowly decelerate
				else{
					velocity.X = Mathf.MoveToward(velocity.X, 0, Speed/4);
				}
			}
			// if the velocity theyre moving at is less than walking speed then walking speed gets updated
			else{
				if (velocity.X < direction.X * Speed && Math.Sign(direction.X) > 0){
					velocity.X += direction.X * Speed/8;
				}
				else if (velocity.X > direction.X * Speed && Math.Sign(direction.X) < 0){
					velocity.X += direction.X * Speed/8;
				}
			}
		}
		// activates if they aren't moving or just recently dashed
		else
		{
			// they don't decelerate until dash is over
			if (DashCharging < 9.5){
				// reduces their movement by a lot (can stop fast on ground)
				if (IsOnFloor()){
					velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
				}
				// reduces their movement by a little if in the air
				else{
					velocity.X = Mathf.MoveToward(velocity.X, 0, Speed/4);
				}
			}
		}
		
		// checks if the dash can be reduced, than reduces it if true
		if (DashCharging > 0){
			DashCharging -= 0.125f;
		}
		// checks if the dash is pressed and if the dash is charged (so player can't infinately dash)
		if (Input.IsActionJustPressed("dash") && DashCharging <= 0f){
			// updates the charge counter so they can't dash for a while
			DashCharging = 10f;
			// if they're in the air this is used, when on the ground this variable gets updated so the player can dash a reasonable distance in air or on ground (because of the way deceleration works)
			float SpeedModifier = 4f;
			//sets velocity to 0 so dash doesnt add to walk speed
			velocity.X = 0;
			// checks if theyre on the ground (and didn't jump) WARNING I doubt that checking if they recently pressed the jump button is helping 
//			if (IsOnFloor() && Input.IsActionPressed("ui_accept") == false){
//				// changes speed mod if on ground
//				SpeedModifier = 8f;
//			}

			// if theyre facing right
			if (PlayerSprite.Scale.X < 0){
				// make them go right fast
				velocity.X += Speed * SpeedModifier;
			}
			// if facing left
			else{
				// make them go left fast
				velocity.X -= Speed * SpeedModifier;
			}
		}
		// if you're pressing go right button WARNING has trouble flipping character if both keys are pressed
		if (Input.IsActionJustPressed("ui_right")){
			// makes you face right
			PlayerSprite.Scale = new Vector2(-1, 1);
			// changes the player's reach square to match
			PlayerReach.Position = new Vector2(16,0);
		}
		// if pressing go left button
		else if (Input.IsActionJustPressed("ui_left")){
			// makes you face left
			PlayerSprite.Scale = new Vector2(1, 1);
			// changes reach area to match
			PlayerReach.Position = new Vector2(-16,0);

		}
		if (Input.IsActionPressed("crouch")){
			var PlayerCollision = GetNode<CollisionShape2D>("CharacterCollision");
			PlayerCollision.Scale = new Vector2 (PlayerCollision.Scale.X, .5f);
		}
		else{
			var PlayerCollision = GetNode<CollisionShape2D>("CharacterCollision");
			PlayerCollision.Scale = new Vector2 (PlayerCollision.Scale.X, 1);
		}
		// sets the changed velocity to the new velocity
		Velocity = velocity;
		GD.Print(velocity.X);
		// tells the node to move based on current velocity
		MoveAndSlide();
	}
}
