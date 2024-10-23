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
    

    
    //Initialize funciton gets the sprite2d node and sets it to the image held by the resource attached to this node
    public void Initialize(EquipableItemScript equipableItem) {
        Sprite2D ResourceImage = GetNode<Sprite2D>("SapplingSprite");
        ResourceImage.Texture = equipableItem.ResourceImage;
    }


    //this happens when the play button is pressed
    public override void _Ready()
	{
        //these lines of code get the resource that is attached to this node, save the filepath so other nodes can access it (like how the EquipNewItem function uses the stats to equip a new item)
        string ResourcePath = "res://Items/EquipableItems/"+Name+"Staff.tres";
        SetMeta("merge_path", ResourcePath);
        //Initalize is used to take any data from the attached resource and apply it to this node
        Initialize(GD.Load<EquipableItemScript>(ResourcePath));
	}

    //this function isn't important as theres no resource gathering in the game
    protected string GenerateResources(string[] input_array){
        Random randomizer = new Random();
        int random_num = randomizer.Next(input_array.Length);
        string resource_name = input_array[random_num];
        return resource_name;
    }

    //this function isn't nessisary since we don't have anything to do with resources or gather resources, but could be used at some point
    protected void ReadyToMine(Area2D miner){
        SetMeta("resource", GenerateResources(resource_array));
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
