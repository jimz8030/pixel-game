using Godot;
using Godot.NativeInterop;
using System;
using System.Numerics;
using System.Security.AccessControl;


public partial class StepHeightArea : Area2D
{
	bool ShouldStepUp;
	CharacterBody2D Player;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		Player = GetParent<CharacterBody2D>();

	}


	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (ShouldStepUp && Player.IsOnWall() && Player.IsOnFloor() && (Input.IsActionPressed("ui_right") || Input.IsActionPressed("ui_left"))){
			Player.Position = new Godot.Vector2 (Player.Position.X, Player.Position.Y - 11);
			ShouldStepUp = false;
			GD.Print("trying to move character up");
		}
		else{
			GD.Print(Player.IsOnWall());
		}
	}

	public void DetectStep(Node2D Body){
		if (Body.IsClass("TileMapLayer")){
			ShouldStepUp = true;
		}
		
		GD.Print(Body.GetClass());

	}
}
