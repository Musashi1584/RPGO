class X2Effect_CloseandPersonal extends X2Effect_Persistent;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local int Tiles;
	local XComGameState_Item SourceWeapon;
	local ShotModifierInfo ShotInfo;
	local array<int> Critboost;

	Critboost = class'Config_Manager'.static.GetConfigIntArray("CLOSE_AND_PERSONAL_CRIT_BOOST");

	SourceWeapon = AbilityState.GetSourceWeapon();
	if(SourceWeapon != none)
	{
		Tiles = Attacker.TileDistanceBetween(Target);
		if(Critboost.Length > 0)
		{
			if(Tiles < Critboost.Length)
			{
				ShotInfo.Value = Critboost[Tiles];
			}
			else //Use last value
			{
				ShotInfo.Value = Critboost[Critboost.Length - 1];
			}
			ShotInfo.ModType = eHit_Crit;
			ShotInfo.Reason = FriendlyName;
			ShotModifiers.AddItem(ShotInfo);
		}
	}
}

defaultproperties
{
	DuplicateResponse=eDupe_Ignore
	EffectName="CloseandPersonal"
}