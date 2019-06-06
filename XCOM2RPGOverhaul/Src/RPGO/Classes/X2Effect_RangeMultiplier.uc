class X2Effect_RangeMultiplier extends X2Effect_Persistent;

var float RangeMultiplier;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate WeaponTemplate;
	local ShotModifierInfo Mod;
	local int Tiles, Modifier;

	if (AbilityState.SourceWeapon != EffectState.ApplyEffectParameters.ItemStateObjectRef)	
		return;

	SourceWeapon = AbilityState.GetSourceWeapon();	
	
	if (Attacker != none && Target != none && SourceWeapon != none)
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());

		if (WeaponTemplate != none)
		{
			Tiles = Attacker.TileDistanceBetween(Target);
			if (WeaponTemplate.RangeAccuracy.Length > 0)
			{
				if (Tiles < WeaponTemplate.RangeAccuracy.Length)
					Modifier = WeaponTemplate.RangeAccuracy[Tiles];
				else  //  if this tile is not configured, use the last configured tile					
					Modifier = WeaponTemplate.RangeAccuracy[WeaponTemplate.RangeAccuracy.Length-1];
			}
		}
	
		if(Modifier < 0){
			Mod.ModType = eHit_Success;
			Mod.Reason = class'XLocalizedData'.default.WeaponRange;
			Mod.Value = int(RangeMultiplier * Modifier);
			ShotModifiers.AddItem(Mod);
		}	
	}
}


defaultproperties
{
	EffectName = "APT_Hawkeye"
	DuplicateResponse = eDupe_Refresh
}