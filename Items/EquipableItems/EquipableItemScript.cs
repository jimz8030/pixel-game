using Godot;
using System;

[GlobalClass]
public partial class EquipableItemScript : Resource
{
	[Export]
	public string MergeFrom {get; set;}
	[Export]
	public string MergeType {get; set;}
	[Export]
	public string DamageType {get; set;}

	[Export]
	public float Damage {get; set;}
	[Export]
	public float AttackSpeed {get; set;}

	//public void EquipableItem() : this(null,null, 0f, 0f) {}

	public void EquipableItem(string mergeFrom, string damageType, string mergeType, float damage, float attackSpeed)
	{
		MergeFrom = mergeFrom;
		MergeType = mergeType;
		DamageType = damageType;
		Damage = damage;
		AttackSpeed = attackSpeed;
	}
}