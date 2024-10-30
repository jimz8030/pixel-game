using Godot;
using System;


public partial class PlayerCamera : Camera2D
{
	CharacterBody2D PlayerBody;
	float TimeRunningRight = 0;
	float SpeedUpCamera = 5;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		PlayerBody = GetParent<Node2D>().GetParent<CharacterBody2D>();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (PlayerBody.Velocity.X >= 500 && TimeRunningRight < 200){
			TimeRunningRight += 3;
			SpeedUpCamera = 10;
		}
		else if (PlayerBody.Velocity.X <= -500 && TimeRunningRight > -200){
			TimeRunningRight -= 3;
			SpeedUpCamera = 10;
		}
		else{
			if (PlayerBody.Velocity.Y < 500){
				SpeedUpCamera = 5;
			}
		}


		if (PlayerBody.Velocity.X > 0 && TimeRunningRight < 200){
			TimeRunningRight += 1;
		}
		else if (PlayerBody.Velocity.X < 0 && TimeRunningRight > -200){
			TimeRunningRight -= 1;
		}
		else{
			if (TimeRunningRight < 3 && TimeRunningRight > -3){
				TimeRunningRight = 0;
			}
			else if (PlayerBody.Velocity.X <= 0 && TimeRunningRight > 0){
				TimeRunningRight -= 3;
			}
			else if (PlayerBody.Velocity.X >= 0 && TimeRunningRight < 0){
				TimeRunningRight += 3;
			}
		}

		//if (PlayerBody.Velocity.Y >= 1000){
			//if (SpeedUpCamera < 200){
			//	SpeedUpCamera += 15f;
			//}
		//}
		if (PlayerBody.Velocity.Y >= 500){
			if (SpeedUpCamera < 50){
				SpeedUpCamera += .1f;
			}
		}
		//GD.Print(SpeedUpCamera);
		Offset = new Vector2(TimeRunningRight,0);
		PositionSmoothingSpeed = SpeedUpCamera;
	}
}
