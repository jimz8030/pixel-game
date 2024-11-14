using Godot;
using System;
using System.ComponentModel;
using System.Numerics;

public partial class ProjectileNode : CharacterBody2D
{
	[Export]
	public ProjectileScript ProjectileType; //= GD.Load<ProjectileScript>("res://Items/Projectiles/BoulderProjectile.tres");

	float WallBounceMod;
	float Radius = 10f;
	public float SizeMod;
	//used to calculate how long the projectile should be alive
	float Lifetime = 10f;
	//makes gravity heavier for specific objects, 1 seems like normal gravity, 0 is no gravity
	float GravityMultiplier = 1f;
	//changes how fast the projectile is going on spawn, should be changed depending on mouse location and maybe how fast the player is moving too
	public Godot.Vector2 Speed = new Godot.Vector2(0,100f);
	public float RotationRadians = 0;

	///gives the projectile different physics depending on its property
	string WallTouchProperty = "bounce";



	public void Initialize(ProjectileScript projectileType){
		WallBounceMod = projectileType.WallBounceMod;
		Radius = projectileType.Radius;
		Lifetime = projectileType.Lifetime;
		GravityMultiplier = projectileType.Gravity;
		WallTouchProperty = projectileType.WallTouchProperty;
		//GD.Print("initalizing");
		GetNode<Sprite2D>("ProjectileImage").Texture = projectileType.ProjectileImage;
	}
    public override void _Ready()
    {
        // base._EnterTree();
		Initialize(ProjectileType);
		//replace this below with new Godot,Vector2(mouse position) this way it goes towards where we want.
		Velocity = Speed.Rotated(RotationRadians);
		//makes a circle colision, sets its radius, then sets the shape property of the projectil's collision to the circle
		CircleShape2D ShapeProperty = new CircleShape2D();
		ShapeProperty.Radius = Radius * SizeMod;
		GetNode<CollisionShape2D>("ProjectileShape").Shape = ShapeProperty;
		//change the size of the picture if possible, this might be bad since the picture might not have the same sizing as the circle (like a fire sprite might be taller and not so cirlcuar)
		GetNode<Sprite2D>("ProjectileImage").Scale = new Godot.Vector2(Radius/4,Radius/4);
		//GD.Print("radius ", Radius);
	}


	public override void _PhysicsProcess(double delta)
	{
		
		//if it's not on the floor it gets affected by gravity. WARNING this will make the projectile faster indefinately (I'm pretty sure), although this might not matter becasue the projectile should be deleted after a certain ammount of time
		if (!IsOnFloor()){
			Velocity += GetGravity() * (float)delta * GravityMultiplier;
		}
		
		//checks the property of the projectile, whether it bounces, get's destroyed on wall, or something else (so far it can only bounce)
		if (WallTouchProperty == "bounce"){
			//if it is on the ground it tries to bounce by changing velocity to the other direction of it's fastest point (also gets halved so it doesn't bounce forever)
			var collision = MoveAndCollide(Velocity * (float)delta);
        	if (collision != null)
			{
				//this actually bounces the projectile
				Velocity = Velocity.Bounce(collision.GetNormal());
				//this changes the velocity so it is less bouncy (by wall bounce mod which should be less than 1)
				Velocity = new Godot.Vector2(Velocity.X * WallBounceMod, Velocity.Y * WallBounceMod);
				
				//used for dealing damage I think. Honestly I coppied bullet code to get bounce to work, but we can definately use this to deal damage and status affects
				if (collision.GetCollider().HasMethod("Hit"))
				{
					collision.GetCollider().Call("Hit");
				}
			}
		}
		else if (WallTouchProperty == "destroy"){
			var collision = MoveAndCollide(Velocity * (float)delta);
        	if (collision != null){
				QueueFree();
			}
		}

		//counts down the lifetime until it's destroyed by QueueFree() function
		Lifetime -= .1f;
		//checks if the object should be destroyed after a certain ammount of time (or is delta frames?)
		if (Lifetime <= 0){
			QueueFree();
		}
	}
}
