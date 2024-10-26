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
	public int RadiusPixels {set; get;}
	[Export]
	public float Gravity {set; get;}
	[Export]
	public float Lifetime {set; get;}

	public void Projectile(Texture2D projectileImage, string wallTouchProperty, int radiusPixels, float gravity, float lifetime)
	{
		ProjectileImage = projectileImage;
		WallTouchProperty = wallTouchProperty;
		Gravity = gravity;
		Lifetime = lifetime;
		RadiusPixels = radiusPixels;
	}
}
