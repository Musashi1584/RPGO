class XMBValue_Ammo extends XMBValue;

function float GetValue(XComGameState_Effect EffectState, XComGameState_Unit UnitState, XComGameState_Unit TargetState, XComGameState_Ability AbilityState)
{
	local XComGameState_Item PrimaryWeapon;

	PrimaryWeapon = UnitState.GetPrimaryWeapon();

	return PrimaryWeapon.Ammo;
}