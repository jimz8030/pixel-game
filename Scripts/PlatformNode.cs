using Godot;
using System;

public partial class PlatformNode : StaticBody2D
{
	public SecondaryScript SecondaryData;
	Sprite2D SecondarySprite;
	CollisionShape2D SecondaryShape;

	public override void _Ready()
	{
		Initialize(SecondaryData);
	}
	public void Initialize(SecondaryScript SecondaryType){
		SecondarySprite = GetNode<Sprite2D>("PlatformImage");
		SecondaryShape = GetNode<CollisionShape2D>("PlatformSize");
		//this.Name = SecondaryType.ResourceName;
		SecondaryShape.Shape = SecondaryType.Shape;
		SecondarySprite.Texture = SecondaryType.SecondaryImage;
	}
}
