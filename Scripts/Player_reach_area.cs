using Godot;
using System;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;

public partial class Player_reach_area : Area2D
{
	[Export]
	public Resource EquippedItem;
	public Area2D[] ReachableItems = new Area2D[2];
	string MergeFrom;
    string MergeType;
    string DamageType;
    float Damage;
    float AttackSpeed;



	//this code changes the stats of this node (which is basically the player's hands) to the new stats of a merged or newly equipped item
	public void EquipNewItem(EquipableItemScript equipableItem) {
        MergeFrom = equipableItem.MergeFrom;
        MergeType = equipableItem.MergeType;
        DamageType = equipableItem.DamageType;
        Damage = equipableItem.Damage;
        AttackSpeed = equipableItem.AttackSpeed;
    }


	//this checks if the resource that the player is trying to gather is mergable, used in the _Input funciton with interact button press
	public bool CheckIfMergable(Variant path){
		bool IsItemMergable = false;
		EquipableItemScript NewItem = GD.Load<EquipableItemScript>(Convert.ToString(path));
		//this checks if the held item can be merged with the resource to make a new item
		if (MergeType == NewItem.MergeFrom){
			IsItemMergable = true;
		}
		return IsItemMergable;
	}


	//this function detects if the area2d is a resource or not. WARNING this code can be improved greatly if there are other kinds of Area2Ds (like an enemy)
	public void GetNearbyArea2D(Area2D ReachableItem){
		if (ReachableItem.Name == "Sappling" || ReachableItem.Name == "Boulder" || ReachableItem.Name == "Fire"){
			//WARNING ReachableItems is an array because there might be mulitple objects within reach, however the currently written code only affects the Area2D that entered last
			ReachableItems[0] = ReachableItem;
			GD.Print(ReachableItems[0].Name+" is within reach");
		}
		else{
			GD.Print("something else is afoot. also area2d name is: "+ReachableItem.Name);
		}


	}


	//this function removes the Area2D from this node, so the player can't harvest the item if they go out of reach
	public void RemoveFarArea2D(Area2D ItemLeaving){
		ReachableItems[0] = null;
		GD.Print(ItemLeaving.Name+" is leaving the player's reach");
	}


	//this detects an input (a key or mouse press)
	public override void _Input(InputEvent @event)
    {
		//not sure what base._Input(@event) does but it was auto generated when I made this funciton and I get the feeling it calls the function on button press
        base._Input(@event);

		//this detects if the player presses the "interact key" which is set to E on ready in the CharacterBody2d.cs script
		if (Input.IsActionJustPressed("interact")) {
			//check if something is within reach
			if (ReachableItems[0] != null){
				GD.Print(ReachableItems[0].Name+" is being interacted with");
				//checks if the resource the player is harvesting and the item they're holding can be merged together
				if (CheckIfMergable(ReachableItems[0].GetMeta("merge_path")))
				{
					//this changes the equipped item the player is holding into the new merged item, then destroys the resource
					EquipNewItem(GD.Load<EquipableItemScript>(Convert.ToString(ReachableItems[0].GetMeta("merge_path"))));
					GD.Print(Damage + " " + DamageType);
					ReachableItems[0].QueueFree();
				}
				else{
					GD.Print("You canot gather this resource yet");
				}
				
			}
			else{
				GD.Print("there is no item in ReachableItems[0] array");
			}
		}
	}


	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//this gets the equipped item resource that this node has, WARNING I need to update this code when we have a save file so that the equipped item isn't the player's hands
		EquipNewItem(GD.Load<EquipableItemScript>("res://Items/EquipableItems/Hands.tres"));
		GD.Print(Damage + " " + DamageType);
	}


	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
