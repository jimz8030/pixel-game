using Godot;
using System;

public partial class Player_reach : Area2D
{
	
	public void GetNearbyArea2D(Node2D Area2D){
		if (Area2D.Name == "Sappling"){
			GD.Print("Sapling confirmed");
		}
		else{
			GD.Print("something else is afoot. also area2d name is: "+Area2D.Name);
		}


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
