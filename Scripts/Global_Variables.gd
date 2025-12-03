extends Node

#Customization
var hair_type : int
var bottom_clothing : bool
var skin : Color
var top_clothing : Array[CompressedTexture2D]
var selected_top : int

#Missions
var time_limit : float
var food_chain_xp : float
var reward_xp : float
var crab_killed : int
var ottle_killed : int
var active_mission : int
var reward_xp_estimate : float

#Ship and Planetoid
var player_ship_pos : Vector2
var player_inv : Array[String]
var taming_strength : float
var player_planetoid_pos : Vector2
var taming_selection : String
