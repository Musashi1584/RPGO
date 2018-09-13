class X2Effect_DangerousGame extends X2Effect_Persistent;

var float DamageMod;
var bool RequireCrit;

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{
	local XComGameState_Unit SourceUnit;
	local array<StateObjectReference> VisInfo, VisInfo2;
	local StateObjectReference UnitRef;
	local bool bFlanked, bIsFlanked;

	SourceUnit = XComGameState_Unit(TargetDamageable);

	bFlanked = false;
	bIsFlanked = false;

	class 'X2TacticalVisibilityHelpers'.static.GetEnemiesFlankedBySource(SourceUnit.ObjectID, VisInfo);
	class 'X2TacticalVisibilityHelpers'.static.GetEnemiesFlankedBySource(Attacker.ObjectID, VisInfo2);

	foreach VisInfo(UnitRef)
	{
		if (Attacker.ObjectID == UnitRef.ObjectID)
			bFlanked = true;
	}

	foreach VisInfo2(UnitRef)
	{
		if (SourceUnit.ObjectID == UnitRef.ObjectID)
			bIsFlanked = true;
	}

	if(bFlanked && bIsFlanked){
	
		if(RequireCrit){
			if(AppliedData.AbilityResultContext.HitResult == eHit_Crit)
				return int(CurrentDamage * DamageMod);
			return 0;
		}
		else
			return int(CurrentDamage * DamageMod);
	}
}

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState) {

	local XComGameState_Unit TargetUnit;
	local array<StateObjectReference> VisInfo, VisInfo2;
	local StateObjectReference UnitRef;
	local bool bFlanked, bIsFlanked;

	TargetUnit = XComGameState_Unit(TargetDamageable);

	bFlanked = false;
	bIsFlanked = false;

	class 'X2TacticalVisibilityHelpers'.static.GetEnemiesFlankedBySource(TargetUnit.ObjectID, VisInfo);
	class 'X2TacticalVisibilityHelpers'.static.GetEnemiesFlankedBySource(Attacker.ObjectID, VisInfo2);

	foreach VisInfo(UnitRef)
	{
		if (Attacker.ObjectID == UnitRef.ObjectID)
			bFlanked = true;
	}

	
	foreach VisInfo2(UnitRef)
	{
		if (TargetUnit.ObjectID == UnitRef.ObjectID)
			bIsFlanked = true;
	}

	if(bFlanked && bIsFlanked){
	
		if(RequireCrit){
			if(AppliedData.AbilityResultContext.HitResult == eHit_Crit)
				return int(CurrentDamage * DamageMod);
			return 0;
		}
		else
			return int(CurrentDamage * DamageMod);
	}

}

