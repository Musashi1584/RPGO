//--------------------------------------------------------------------------------------- 
//  FILE:    X2Effect_Infighter
//  AUTHOR:  John Lumpkin (Pavonis Interactive)
//  PURPOSE: Sets up dodge bonuses for Infighter (Soldier gains +25 dodge against attacks within four tiles (including melee)
//---------------------------------------------------------------------------------------
class X2Effect_Infighter extends X2Effect_Persistent;

var int DodgeMod, CritMod, HitMod;
var int TileRange;
var bool bWithin;

function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
    local ShotModifierInfo				ShotInfo;
	local int							Tiles;

	if (Target.IsImpaired(false) || Target.IsBurning() || Target.IsPanicked())
		return;

	Tiles = Attacker.TileDistanceBetween(Target);
	
	ShotInfo.ModType = eHit_Graze;
	ShotInfo.Reason = FriendlyName;
	ShotInfo.Value = DodgeMod;
		       
	if (Tiles <= TileRange && bWithin)
		ShotModifiers.AddItem(ShotInfo);
	else if (Tiles >= TileRange && !bWithin)
		ShotModifiers.AddItem(ShotInfo);
	else return;
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{

    local ShotModifierInfo				ShotInfo, ShotInfo2;
	local int							Tiles;

	Tiles = Attacker.TileDistanceBetween(Target);   
	ShotInfo.ModType = eHit_Crit;
	ShotInfo.Reason = FriendlyName;
	ShotInfo.Value = CritMod;
	
	ShotInfo2.ModType = eHit_Success;
	ShotInfo2.Reason = FriendlyName;
	ShotInfo2.Value = HitMod;
		    
	if (Tiles <= TileRange && bWithin)
	{
		ShotModifiers.AddItem(ShotInfo);
		ShotModifiers.AddItem(ShotInfo2);
	}
	else if (Tiles >= TileRange && !bWithin)
	{
		ShotModifiers.AddItem(ShotInfo);
		ShotModifiers.AddItem(ShotInfo2);
	}
	else return;
}