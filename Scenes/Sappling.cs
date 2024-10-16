using Godot;
using System;
using System.Collections;
using System.Runtime.InteropServices;
using static Godot.GD;
//Jason McGraw 10/16/24

public partial class Sappling : Area2D
{
    //bool player_nearby = false;
    //detects when player or another phisicsbody2d enters the area
    protected void OnBodyEnter(Node2D PhysicsBody2D){
        GD.Print("Collision confirmed");
        //player_nearby = true;

    }
    //detects when player or another phisicsbody2d leaves it's area
    protected void OnBodyExit(Node2D PhysicsBody2D){
        GD.Print("collision exited");
        //player_nearby = false;
    }
}
