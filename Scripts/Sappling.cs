using Godot;
using System;
using System.Collections;
using System.Runtime.InteropServices;
using static Godot.GD;
//Jason McGraw 10/16/24

public partial class Sappling : Area2D
{
    string[] resource_array = {"leaf","stick"};
    
    public override void _Ready()
	{
		SetMeta("resource", GetResource(resource_array));
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
