class X2Effect_Scope extends X2Effect_Persistent config(ExtendedUpgrades);

var array<int> SCOPE_RANGE_CHANGE;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local int Tiles;
	local XComGameState_Item SourceWeapon;
	local ShotModifierInfo ShotInfo;

	SourceWeapon = AbilityState.GetSourceWeapon();
	//`LOG("X2Effect_ScopeRange.GetToHitModifiers" @ SourceWeapon.ObjectID @ EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID @ SCOPE_RANGE_CHANGE.Length,, 'ExtendedUpgrades');
	if(SourceWeapon != none && SourceWeapon.ObjectID == EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID)
	{

		Tiles = Attacker.TileDistanceBetween(Target);
		if(SCOPE_RANGE_CHANGE.Length > 0)
		{
			if(Tiles < SCOPE_RANGE_CHANGE.Length)
			{
				ShotInfo.Value = SCOPE_RANGE_CHANGE[Tiles];
			}
			else //Use last value
			{
				ShotInfo.Value = SCOPE_RANGE_CHANGE[SCOPE_RANGE_CHANGE.Length - 1];
			}

			//`LOG("X2Effect_ScopeRange.GetToHitModifiers" @ SourceWeapon.GetMyTemplateName() @ "modifying range by" @ ShotInfo.Value,, 'ExtendedUpgrades');
			ShotInfo.ModType = eHit_Success;
			ShotInfo.Reason = FriendlyName; //class'XLocalizedData'.default.WeaponRange;
			ShotModifiers.AddItem(ShotInfo);
		}
	}
}
