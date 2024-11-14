using Godot;
using System;

[GlobalClass]
public partial class SecondaryScript : Resource
{
	[Export]
	public Texture2D SecondaryImage {set; get;}
	[Export]
	public Shape2D Shape {get; set;}
	[Export]
	public float ChargeTime {get; set;}


	public void Secondary(Texture2D secondaryImage, Shape2D shape, float chargeTime)
	{
		SecondaryImage = secondaryImage;
		Shape = shape;
		ChargeTime = chargeTime;
	}

}
