using Godot;
using System;

public partial class ProjectileNode : CharacterBody2D
{
	//used to calculate how high to bounce the projectile on ground touch
	float FallingVelocity;
	public override void _PhysicsProcess(double delta)
	{
		Vector2 velocity = Velocity;
		//if it's not on the floor it gets affected by gravity
		if (!IsOnFloor()){
			velocity += GetGravity() * (float)delta;
			//this stores the fastest point downward, it's used later to calculate bounce
			if (FallingVelocity < velocity.Y){
				FallingVelocity = Velocity.Y;
			}
		}
		//if it is on the ground it tries to bounce by changing velocity to the other direction of it's fastest point (also gets halved so it doesn't bounce forever)
		else{
			velocity.Y = -FallingVelocity/2;
			FallingVelocity = velocity.Y;
		}
		Velocity = velocity;
		MoveAndSlide();
	}
}
