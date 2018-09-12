class X2Effect_DefendingDamage extends X2Effect_Persistent;

var bool PercentDamage;
var int DamageMod;
var float PercentDamageMod;

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{
	if(PercentDamage)
		return int(float(CurrentDamage) * PercentDamageMod);
	else
		return DamageMod;
}