using Godot;
using System;
using System.Collections;
using System.Runtime.InteropServices;
using static Godot.GD;


public partial class Sappling : Area2D
{
    protected void OnBodyEnter(Node2D PhysicsBody2D){
        GD.Print("Collision confirmed");
    }
}
