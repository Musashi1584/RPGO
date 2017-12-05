class X2Effect_ShotgunDamageModifierCoverType extends X2Effect_Persistent config (RPG);

var config float HalfCovertModifier;
var config float FullCovertModifier;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit TargetUnit;
	local XComGameState_Item WeaponState;
	local GameRulesCache_VisibilityInfo VisInfo;
	local ECoverType CoverType;
	local int HistoryIndex, DamageModifier;

	History = `XCOMHISTORY;
	HistoryIndex = History.GetCurrentHistoryIndex();

	//`LOG(Class.Name @ GetFuncName() @ AppliedData.AbilityResultContext.HitResult @ "bCanTakeCover" @ TargetUnit.GetMyTemplate().bCanTakeCover,, 'RPG');

	if (!class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult))
		return 0;

	TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(AppliedData.AbilityInputContext.PrimaryTarget.ObjectID));
	WeaponState = XComGameState_Item(History.GetGameStateForObjectID(AppliedData.ItemStateObjectRef.ObjectID));

	if (TargetUnit != none && WeaponState != none && TargetUnit.GetMyTemplate().bCanTakeCover)
	{
		if (X2WeaponTemplate(WeaponState.GetMyTemplate()).WeaponCat != 'shotgun')
			return 0;

		`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, TargetUnit.ObjectID, VisInfo, HistoryIndex);
		
		CoverType = VisInfo.TargetCover;

		if (CoverType == CT_None)
			return 0;
		
		if (CoverType == CT_MidLevel)
		{
			DamageModifier = int(CurrentDamage * default.HalfCovertModifier) * -1;
		}

		if (CoverType == CT_Standing)
		{
			DamageModifier = int(CurrentDamage * default.FullCovertModifier) * -1;
		}

		//`LOG(Class.Name @ GetFuncName() @ "CoverType Damage Modifier:" @ DamageModifier,, 'RPG');

		if (CurrentDamage + DamageModifier > 0)
		{
			return DamageModifier; 
		}
	}

	return 0;
}

defaultproperties
{
	EffectName=ShotgunDamageModifierCoverType
	//DuplicateResponse=eDupe_Refresh
}