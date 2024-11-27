using Godot;
using System;

[GlobalClass]
public partial class ProjectileScript : Resource
{
	[Export]
	public Texture2D ProjectileImage {set; get;}
	[Export]
	public string WallTouchProperty {set; get;}
	[Export]
	public float Damage {set; get;}
	[Export]
	public float WallBounceMod {set; get;}
	[Export]
	public float Radius {set; get;}
	[Export]
	public float Gravity {set; get;}
	[Export]
	public float Lifetime {set; get;}

	public void Projectile(Texture2D projectileImage, string wallTouchProperty, float damage, float wallBounceMod, float radius, float gravity, float lifetime)
	{
		ProjectileImage = projectileImage;
		WallBounceMod = wallBounceMod;
		Damage = damage;
		WallTouchProperty = wallTouchProperty;
		Gravity = gravity;
		Lifetime = lifetime;
		Radius = radius;
	}
}
