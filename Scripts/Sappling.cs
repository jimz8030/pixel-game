using Godot;
using System;
using System.Collections;
using System.Runtime.InteropServices;
using static Godot.GD;
//Jason McGraw 10/16/24

public partial class Sappling : Area2D
{
    [Export]
    public Resource ResourceType;
    string[] resource_array = {"leaf","stick"};
    
    //string MergeFrom;
    //string MergeType;
    //string DamageType;
    //float Damage;
    //float AttackSpeed;
    
    //public void Initialize(EquipableItemScript equipableItem) {
    //    MergeFrom = equipableItem.MergeFrom;
    //    MergeType = equipableItem.MergeType;
    //    DamageType = equipableItem.DamageType;
    //    Damage = equipableItem.Damage;
    //    AttackSpeed = equipableItem.AttackSpeed;
    //}

    public override void _Ready()
	{
		GD.PrintErr("Jason should probably get rid of ReadyToMineFunction, as well as the SetMeta functions in the Sappling.cs (unless we use the setmeta functions)");
        //Initialize(GD.Load<EquipableItemScript>("res://Items/EquipableItems/"+Name+"Staff.tres"));
        string ResourcePath = "res://Items/EquipableItems/"+Name+"Staff.tres";
        SetMeta("merge_path", ResourcePath);
	}

    protected string GetResource(string[] input_array){
        Random randomizer = new Random();
        int random_num = randomizer.Next(input_array.Length);
        string resource_name = input_array[random_num];
        return resource_name;
    }


    protected void ReadyToMine(Area2D miner){
        SetMeta("resource", GetResource(resource_array));
    }

    //bool player_nearby = false;
    //detects when player or another phisicsbody2d enters the area
    protected void OnBodyEnter(Node2D PhysicsBody2D){
        
        //I think this is errelavant until we have an animation (like when a player walks by it moves)
    }
    //detects when player or another phisicsbody2d leaves it's area
    protected void OnBodyExit(Node2D PhysicsBody2D){
        
    }
}
