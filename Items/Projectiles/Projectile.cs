using Godot;
using System;

public partial class Projectile : Resource
{
	[Export]
	Texture2D ProjectileImage {set; get;}
	bool CanBounce {set; get;}
	float Gravity {set; get;}


	public void EquipableItem(Texture2D projectileImage, bool canBounce, float gravity)
	{
		ProjectileImage = projectileImage;
		CanBounce = canBounce;
		Gravity = gravity;
	}
}
