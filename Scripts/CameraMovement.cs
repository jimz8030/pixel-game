using Godot;
using System;

public partial class CameraMovement : Node2D
{
	Node2D PlayerReachArea;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		PlayerReachArea = GetParent().GetNode<Area2D>("PlayerReachArea");
	}

	
	public override void _Input(InputEvent @event)
    {
        base._Input(@event);
		
		//not important because Player_reach_area is handling the inputs (I would do things here, but the variables don't transfer well)
	} 


	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _PhysicsProcess(double delta)
	{
		
		Vector2 AttackPosition = GetGlobalMousePosition();
		AttackPosition.X -= GetParent<CharacterBody2D>().Position.X;
		AttackPosition.Y -= GetParent<CharacterBody2D>().Position.Y;
		float C = (float)Math.Sqrt(Math.Pow(AttackPosition.X, 2) + Math.Pow(AttackPosition.Y, 2));
		
		if (C > 100){
			Position = new Vector2 (AttackPosition.X / C * 100, AttackPosition.Y / C * 100);
		}
		else{
			Vector2 SelfPosition = Position;
			
			if (Position.X < 2 && Position.X > -2){
				SelfPosition = new Vector2 (0, SelfPosition.Y);
			}
			else if (Position.X > 0){
			SelfPosition = new Vector2 (SelfPosition.X -= 1, SelfPosition.Y);
			}
			else{
			SelfPosition = new Vector2 (SelfPosition.X += 1, SelfPosition.Y);
			}

			if (Position.Y < 2 && Position.Y > -2){
				SelfPosition = new Vector2 (SelfPosition.X, 0);
			}
			else if (Position.Y > 0){
			SelfPosition = new Vector2 (SelfPosition.X, SelfPosition.Y -=1);
			}
			else{
			SelfPosition = new Vector2 (SelfPosition.X, SelfPosition.Y +=1);
			}
			Position = SelfPosition;
		}

		
		// if (C >= 100){
			// Vector2 ScreenSize = GetViewport().GetVisibleRect().Size;
			// Position = new Vector2 (0, 100);
			// float MousePosX = AttackPosition.X-ScreenSize.X/2;
			// float MousePosY = AttackPosition.Y-ScreenSize.Y/2;
			// float AngleOfMouse = (float)Math.Atan2(MousePosY, MousePosX);
			// float RotationRadians = AngleOfMouse + -(float)Math.PI/2;
			// Position.Rotated(RotationRadians);
		//}
	}
}
