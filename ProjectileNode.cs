using Godot;
using System;
using System.ComponentModel;
using System.Numerics;

public partial class ProjectileNode : CharacterBody2D
{
	//used to calculate how high to bounce the projectile on ground touch
	float FallingVelocity;
	
	public override void _Ready(){
	FloorStopOnSlope = false;
	Velocity = new Godot.Vector2(0,10);
	}
	public override void _PhysicsProcess(double delta)
	{
		Godot.Vector2 velocity = Velocity;
		//if it's not on the floor it gets affected by gravity
		if (!IsOnFloor()){
			Velocity += GetGravity() * (float)delta;
			//this stores the fastest point downward, it's used later to calculate bounce
			if (FallingVelocity < Velocity.Y){
				FallingVelocity = Velocity.Y;
			}
		}
		//if it is on the ground it tries to bounce by changing velocity to the other direction of it's fastest point (also gets halved so it doesn't bounce forever)
		var collision = MoveAndCollide(Velocity * (float)delta);
        if (collision != null)
        {
            GD.Print("got this far");
			Velocity = Velocity.Bounce(collision.GetNormal());
            Velocity = new Godot.Vector2(Velocity.X/2, Velocity.Y/2);
			//used for dealing damage I think
			if (collision.GetCollider().HasMethod("Hit"))
            {
                GD.Print("Bounce activating");
				collision.GetCollider().Call("Hit");
            }
        }
		
		//else{
			
		//}
		// 	float SlopeDegrees = (float)(180 * GetFloorAngle() / Math.PI);
		// 	//GD.Print(SlopeDegrees, " is slope degrees");
		// 	//GD.Print(FallingVelocity, " is falling velocity p/s");
		// 	velocity.Y = -FallingVelocity * 6 / 5 * SlopeDegrees / 90;
		// 	FallingVelocity = velocity.Y;
		// 	velocity.X = -velocity.Y; // * FallingVelocity * 1.67f * SlopeDegrees / 90;
		// 	//GD.Print(velocity.X, " is velocity x\n", velocity.Y, " is velocity.Y");
		// 	if (Input.IsActionPressed("ui_accept")){
		// 		GD.Print(SlopeDegrees);
		// 	}
		// }
		
		
		
		//Velocity = velocity;
		//MoveAndSlide();
	}
}
