using Godot;
using System;
using System.Linq;

public partial class Player_reach_area : Area2D
{
	public Area2D[] items_in_reach = new Area2D[2];
	public void GetNearbyArea2D(Area2D ReachableItem){
		if (ReachableItem.Name == "Sappling"){
			//WARNING items_in_reach is an array because there might be mulitple objects within reach, however the currently written code only affects the Area2D that entered last
			items_in_reach[0] = ReachableItem;
			GD.Print(items_in_reach[0].Name+" is within reach");
		}
		else{
			GD.Print("something else is afoot. also area2d name is: "+ReachableItem.Name);
		}


	}

	public void RemoveFarArea2D(Area2D ItemLeaving){
		items_in_reach[0] = null;
		GD.Print(ItemLeaving.Name+" is leaving the player's reach");
	}

	public override void _Input(InputEvent @event)
    {
        base._Input(@event);
		if (Input.IsActionJustPressed("interact")) {
			if (items_in_reach[0] != null){
				GD.Print(items_in_reach[0].Name+" is being deleted");
				items_in_reach[0].QueueFree();
			}
			else{
				GD.Print("there is no item in items_in_reach[0] array");
			}
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
