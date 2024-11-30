using Godot;
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Runtime.Intrinsics.X86;

public partial class Player_reach_area : Area2D
{
	[Export]
	public Resource EquippedItem;
	public Node2D[] ReachableItems = new Node2D[2];
	string MergeFrom;
	string ElementName;
	string DamageType;
	string SecondaryName = "";
	float Damage;
	float AttackSpeed;
	float ProjectileVelocity;
	private float AttackCharging;
	private float MaxSpecialCharge;
	private float SpecialCharging;
	private const float MaxCoyoteAttackTime = 1f;
	private float CurrentCoyoteAttackTime;



	//this code changes the stats of this node (which is basically the player's hands) to the new stats of a merged or newly equipped item
	public void EquipNewItem(EquipableItemScript equipableItem) {

		MergeFrom = equipableItem.MergeFrom;
		ElementName = equipableItem.MergeType;
		DamageType = equipableItem.DamageType;
		Damage = equipableItem.Damage;
		AttackSpeed = equipableItem.AttackSpeed;
		ProjectileVelocity = equipableItem.ProjectileVelocity;
		SetMeta("MergeType", ElementName);
		SetMeta("AttackSpeed", AttackSpeed);

		AttackCharging = 0;
		// sets the charge of special. WARNING would be best to change depending on the type of special

		int SecondaryNum = GetRandomArrayNum(equipableItem.PotentialSecondary);
		SecondaryName = equipableItem.PotentialSecondary[SecondaryNum];
		if (ElementName != "Nothing"){
			SecondaryScript SpecialInfo = GD.Load<SecondaryScript>("res://Resources/Secondaries/" +ElementName + SecondaryName+".tres");
			MaxSpecialCharge = AttackSpeed * SpecialInfo.ChargeTime;
		}
		
		
		GD.Print(SecondaryName);
	}

	private int GetRandomArrayNum(Godot.Collections.Array<string> GDArray){
		// CONTINUE get the length of the array then return a random number in the array
		Random rnd = new Random();
		int ArrayNum = rnd.Next(GDArray.Count());
		GD.Print(ArrayNum);
		return ArrayNum;
	}


	//this checks if the resource that the player is trying to gather is mergable, used in the _Input funciton with interact button press
	public bool CheckIfMergable(Variant path){
		bool IsItemMergable = false;
		EquipableItemScript NewItem = GD.Load<EquipableItemScript>(Convert.ToString(path));
		//this checks if the held item can be merged with the resource to make a new item
		if (ElementName == NewItem.MergeFrom){
			IsItemMergable = true;
		}
		return IsItemMergable;
	}


	//this function detects if the area2d is a resource or not. WARNING this code can be improved greatly if there are other kinds of Area2Ds (like an enemy)
	public void GetNearbyArea2D(Area2D ReachableItem){
		GD.Print(ReachableItem.Name);
		// checks if the thing in reach is a resource WARNING (manually updating this for each type of resource will be a pain, find a better solution before you get too far)
		if (ReachableItem.Name == "Sapling" || ReachableItem.Name == "Boulder" || ReachableItem.Name == "Fire"){
			//WARNING ReachableItems is an array because there might be mulitple objects within reach, however the currently written code only affects the Area2D that entered last
			ReachableItems[0] = ReachableItem;
		}
		// if the item isn't a resource or isn't found
		else{
			GD.Print("something else is afoot. also area2d name is: "+ReachableItem.Name);
		}
	}


	public void GetNerbyBody(Node2D body){
		if (body.Name == "NPC"){
			GD.Print("you reached the NPC");
			ReachableItems[0] = body;
		}
		else{
			GD.Print("something else is afoot. also body name is: ", body.Name, "the class name is ", body.GetType());
		}
	}


	//this function removes the Area2D from this node, so the player can't harvest the item if they go out of reach
	public void RemoveFarArea2D(Area2D ItemLeaving){
		// sets the rechable item to null WARNING when this code can fit multiple resources update this to match
		ReachableItems[0] = null;
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
				if (ReachableItems[0].Name == "NPC"){
					if (Input.IsActionPressed("crouch")){
						Vector2 NewPos = new Vector2 (ReachableItems[0].GlobalPosition.X, ReachableItems[0].GlobalPosition.Y -20);
						GetParent<CharacterBody2D>().GlobalPosition = NewPos;
					}
					else{
						//CHANGE put talking to npc here
					}
					GD.Print("class is ", ReachableItems[0]);
				}
				//checks if the resource the player is harvesting and the item they're holding can be merged together
				else if (CheckIfMergable(ReachableItems[0].GetMeta("merge_path")))
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
		if (Input.IsActionJustPressed("attack")){
			CurrentCoyoteAttackTime = MaxCoyoteAttackTime;
		}

		if (Input.IsActionJustPressed("special")){
			
			if (SpecialCharging <= 0){
				SpecialCharging = MaxSpecialCharge;
				// basically an if statement saying if secondary name is a string that ends with ___ (and we can repete that instead of writing new if or else if statements)
				switch(SecondaryName){
					// checks if the staff has the Platform at the end of their name, so the specials "Boulder Platform" and "Sapling Platform" are both under the platform category
					case string s when s == "Platform":
						// gets the position of the mouse to use
						Vector2 SpecialPos = GetGlobalMousePosition();
						// loads the platform scene
						Godot.PackedScene SpecialScene = GD.Load<PackedScene>("res://Scenes/platform.tscn");
						// gets the platform node to work with
						PlatformNode Platform = (PlatformNode)SpecialScene.Instantiate();
						// sets the position of the node to the position of the mouse
						Platform.GlobalPosition = SpecialPos;
						// gives the platform the specific data on the special it's using so when it enters the tree it can change it's size and how it looks.
						Platform.SecondaryData = GD.Load<SecondaryScript>("res://Resources/Secondaries/"+ElementName+SecondaryName+".tres");
						// puts the platform into the game
						GetParent<CharacterBody2d>().MainNode.AddChild(Platform);
						// breaks the case statement
						break;
					// checks if 
					case string s when s == "Cluster":// maybe this should be called catapult
						GD.Print("Cluster secondary still unmade");
						SpawnProjectile(100, 4);
						// launch a big ball that does high damage
						break;
					
					case string s when s == "Stream":
						// continuously blast a creature with an element. Like a flame thrower
						break;
					case string s when s == "Cattletrops":// maybe rename this
						// place element behind you as you move
						break;
					// if none of the above match, then this runs
					default:
						GD.Print(SecondaryName + " is unknown or we haven't made mechanics for it.");
						break;
				}
			}
			//WARNING this will change when different secondaries are avalable for use
			


			// CONTINUE
		}
		
	}


	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		//this gets the equipped item resource that this node has, WARNING I need to update this code when we have a save file so that the equipped item isn't the player's hands
		EquipNewItem(GD.Load<EquipableItemScript>("res://Resources/EquipableItems/Hands.tres"));
		GD.Print(Damage + " " + DamageType);
		SetMeta("MergeType", ElementName);
	}


	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		// reduces special charging time if its greater than 0
		if (SpecialCharging > 0){
			SpecialCharging -= 0.125f;
		}

		// reduces attack charging if it's positive (can't attack while charging)
		if (AttackCharging > 0) {
			AttackCharging -= 0.125f;
		}

		// reduces coyote attack time
		if (CurrentCoyoteAttackTime > 0){
			CurrentCoyoteAttackTime -= .125f;
		}
		
		// checks if player pushed the attack button and if they can attack
		if (CurrentCoyoteAttackTime > 0 && AttackCharging <= 0){
			//reset cooldown on attack
			AttackCharging = AttackSpeed;
			
			SpawnProjectile(100, 1);
			
		}
	}


	private void SpawnProjectile(float speedMod,float sizeMod = 1){
		//spawn projectile in center of player_reach_area, then make it move toward where person clicked
		Godot.PackedScene ProjectileScene = GD.Load<PackedScene>("res://Scenes/projectile.tscn");
		ProjectileNode Projectile = (ProjectileNode)ProjectileScene.Instantiate();
		// sets the speed of the projectile
		Projectile.Speed = new Vector2 (0,speedMod*ProjectileVelocity);
		Projectile.RotationRadians = GetMouseAngle();
		//sets the right resource to attack. It does this by getting the file path of the resource and using its specific name to find it. WARNING might want to set the resource to attack in the player reach area script
		Projectile.ProjectileType = GD.Load<ProjectileScript>("res://Resources/Projectiles/" + ElementName + "Projectile.tres");
		// this makes the projectile different sizes for different attacks
		Projectile.SizeMod = sizeMod;
		//this sets the projectile position to the player
		Projectile.Position = GetParent<CharacterBody2D>().Position;
		//this adds the player reach position to the spawn location
		Projectile.Position = new Vector2 (Projectile.Position.X + Position.X, Projectile.Position.Y);
		//this puts the projectile into the scene
		GetParent<CharacterBody2d>().MainNode.AddChild(Projectile);
	}


	private float GetMouseAngle(){
		//gets the size of the screen and where the cursor is to calculate projectile velocity
		Vector2 AttackPosition = GetGlobalMousePosition();
		//subracts half of the screen from where the mouse is (gets direction of mouse relative to player reach area)
		float MousePosX = AttackPosition.X-GlobalPosition.X;
		float MousePosY = AttackPosition.Y-GlobalPosition.Y;
		float AngleOfMouse = (float)Math.Atan2(MousePosY, MousePosX);
		return AngleOfMouse + -(float)Math.PI/2;
	}
}
