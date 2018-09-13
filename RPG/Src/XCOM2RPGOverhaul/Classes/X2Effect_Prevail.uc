class X2Effect_Prevail extends X2Effect_Persistent;

var int CritMod;
var float DamageReduction;

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState) {

	if ( UnitState.GetCurrentStat(eStat_HP) < 0.5 * UnitState.GetMaxStat(eStat_HP) ) 
		ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.RunAndGunActionPoint);
		
}

function EffectAddedCallback(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState) {
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(kNewTargetState);
	if (UnitState != none) {
		ModifyTurnStartActionPoints(UnitState, UnitState.ActionPoints, none);
	}
}

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{
	local XComGameState_Unit ThisUnit;
	local int DamageMod;
	local float AttackerHealth;
	local float DefenderHealth;

	ThisUnit = XComGameState_Unit(TargetDamageable);

	DefenderHealth = ThisUnit.GetCurrentStat(eStat_HP)/ThisUnit.GetMaxStat(eStat_HP);
	AttackerHealth = Attacker.GetCurrentStat(eStat_HP)/Attacker.GetMaxStat(eStat_HP);

	if (AttackerHealth > DefenderHealth)
	{
		//Reduce damage taken by 50% if relatively unhealthier than opponents
		DamageMod = -int(float(CurrentDamage) * (DamageReduction));
	}
	
	return DamageMod;
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
    local XComGameState_Item	SourceWeapon;
    local ShotModifierInfo		ShotInfo;
	local float AttackerHealth;
	local float DefenderHealth;
	
    SourceWeapon = AbilityState.GetSourceWeapon();    
    if(SourceWeapon != none)	
	{

		AttackerHealth = Attacker.GetCurrentStat(eStat_HP)/Attacker.GetMaxStat(eStat_HP);
		DefenderHealth = Target.GetCurrentStat(eStat_HP)/Target.GetMaxStat(eStat_HP);

		if (DefenderHealth > AttackerHealth)
		{
			//Increase crit by 25 if unhealthier than opponent
			ShotInfo.ModType = eHit_Crit;
			ShotInfo.Reason = FriendlyName;
			ShotInfo.Value = CritMod;
			ShotModifiers.AddItem(ShotInfo);
		}
	}
}

defaultproperties
{
	EffectName = "MNT_Prevail"
	DuplicateResponse = eDupe_Refresh
	EffectAddedFn=EffectAddedCallback
}