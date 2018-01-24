class X2Effect_Hardened extends X2Effect_BonusArmor;

var float DamageReductionPct;

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{
	return int(-1.0 * float(CurrentDamage) * DamageReductionPct / 100.0);
}
