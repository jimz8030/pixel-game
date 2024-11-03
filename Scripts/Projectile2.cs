using Godot;
using System;

public partial class Projectile2 : RigidBody2D
{
	Vector2 Speed = new Vector2(0,100);
	
	public override void _IntegrateForces(PhysicsDirectBodyState2D state)
    {
        if (Input.IsActionPressed("ui_up"))
            state.ApplyForce(Speed.Rotated(Rotation));
        else
            state.ApplyForce(new Vector2());

        var rotationDir = 0;
        if (Input.IsActionPressed("ui_right"))
            rotationDir += 1;
        if (Input.IsActionPressed("ui_left"))
            rotationDir -= 1;
        //state.ApplyTorque(rotationDir * _torque);
    }
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
