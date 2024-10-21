using Godot;
using System;
using System.Linq;

public partial class Player_reach_area : Area2D
{
	public Area2D[] items_in_reach = new Area2D[1];
	public void GetNearbyArea2D(Area2D ReachableItem){
		if (ReachableItem.Name == "Sappling"){
			GD.Print("Resource the player is gathering = " + ReachableItem.GetMeta("resource"));
			items_in_reach[0] = ReachableItem;
			GD.Print(items_in_reach);
			GD.PrintErr("Jason needs to work on destroying the plant when player pushes interact button (E)");
			//Area2D.QueueFree();
		}
		else{
			GD.Print("something else is afoot. also area2d name is: "+ReachableItem.Name);
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
