using Godot;
using System;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;

public partial class Player_reach_area : Area2D
{
	[Export]
	public Resource EquippedItem;
	public Area2D[] items_in_reach = new Area2D[2];
	string MergeFrom;
    string MergeType;
    string DamageType;
    float Damage;
    float AttackSpeed;

	public void EquipNewItem(EquipableItemScript equipableItem) {
        MergeFrom = equipableItem.MergeFrom;
        MergeType = equipableItem.MergeType;
        DamageType = equipableItem.DamageType;
        Damage = equipableItem.Damage;
        AttackSpeed = equipableItem.AttackSpeed;
    }

	public bool CheckIfMergable(Variant path){
		bool IsItemMergable = false;
		EquipableItemScript NewItem = GD.Load<EquipableItemScript>(Convert.ToString(path));
		if (NewItem.MergeFrom == MergeType){
			IsItemMergable = true;
		}
		return IsItemMergable;
	}


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
				Variant MergePotential = items_in_reach[0].GetMeta("merge_path");
				if (CheckIfMergable(items_in_reach[0].GetMeta("merge_path")))
				{
					EquipNewItem(GD.Load<EquipableItemScript>(Convert.ToString(items_in_reach[0].GetMeta("merge_path"))));
					GD.Print(AttackSpeed);
				}
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
		//this gets the equipped item resource that this node has, WARNING I need to update this code when we have a save file so that the equipped item isn't the player's hands
		EquipNewItem(GD.Load<EquipableItemScript>("res://Items/EquipableItems/Hands.tres"));
		GD.Print(AttackSpeed);
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
