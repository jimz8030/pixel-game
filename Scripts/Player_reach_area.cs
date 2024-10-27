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
    string CurrentMergeType;
    string DamageType;
    float Damage;
    float AttackSpeed;
	private float AttackCharging;



	//this code changes the stats of this node (which is basically the player's hands) to the new stats of a merged or newly equipped item
	public void EquipNewItem(EquipableItemScript equipableItem) {
        MergeFrom = equipableItem.MergeFrom;
        CurrentMergeType = equipableItem.MergeType;
        DamageType = equipableItem.DamageType;
        Damage = equipableItem.Damage;
        AttackSpeed = equipableItem.AttackSpeed;
		SetMeta("MergeType", CurrentMergeType);
		SetMeta("AttackSpeed", AttackSpeed);
		AttackCharging = 0;
    }


	//this checks if the resource that the player is trying to gather is mergable, used in the _Input funciton with interact button press
	public bool CheckIfMergable(Variant path){
		bool IsItemMergable = false;
		EquipableItemScript NewItem = GD.Load<EquipableItemScript>(Convert.ToString(path));
		//this checks if the held item can be merged with the resource to make a new item
		if (CurrentMergeType == NewItem.MergeFrom){
			IsItemMergable = true;
		}
		return IsItemMergable;
	}


	//this function detects if the area2d is a resource or not. WARNING this code can be improved greatly if there are other kinds of Area2Ds (like an enemy)
	public void GetNearbyArea2D(Area2D ReachableItem){
		if (ReachableItem.Name == "Sapling" || ReachableItem.Name == "Boulder" || ReachableItem.Name == "Fire"){
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
		if (Input.IsActionJustPressed("attack") && AttackCharging <= 0){
			//reset cooldown on attack
			AttackCharging = AttackSpeed;
			//gets the size of the screen and where the cursor is to calculate projectile velocity
			Vector2 ScreenSize = GetViewport().GetVisibleRect().Size;
			Vector2 AttackPosition = GetViewport().GetMousePosition();
			//spawn projectile in center of player_reach_area, then make it move toward where person clicked
			Godot.PackedScene ProjectileScene = GD.Load<PackedScene>("res://Scenes/projectile.tscn");
			ProjectileNode Projectile = (ProjectileNode)ProjectileScene.Instantiate();
			//subracts half of the screen from where the mouse is (gets direction of mouse relative to center of screen) WARNING this will cause minor problems if player isn't centered (like if we add camera movement stuff)
			Projectile.SpeedX = AttackPosition.X-ScreenSize.X/2;
			Projectile.SpeedY = AttackPosition.Y-ScreenSize.Y/2;
			//sets the right resource to attack. It does this by getting the file path of the resource and using its specific name to find it. WARNING might want to set the resource to attack in the player reach area script
			Projectile.ProjectileType = GD.Load<ProjectileScript>("res://Items/Projectiles/" + CurrentMergeType + "Projectile.tres");
			//this sets the projectile position to the player
			Projectile.Position = GetParent<CharacterBody2D>().Position;
			//this adds the player reach position to the spawn location
			Projectile.Position = new Vector2 (Projectile.Position.X + Position.X, Projectile.Position.Y);
			//this puts the projectile into the scene
			GetParent<CharacterBody2d>().MainNode.AddChild(Projectile);
			GD.Print("just attacked");
		}
	}


	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//this gets the equipped item resource that this node has, WARNING I need to update this code when we have a save file so that the equipped item isn't the player's hands
		EquipNewItem(GD.Load<EquipableItemScript>("res://Items/EquipableItems/Hands.tres"));
		GD.Print(Damage + " " + DamageType);
		SetMeta("MergeType", CurrentMergeType);
	}


	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		AttackCharging -= 0.1f;
	}
}
