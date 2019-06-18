//-----------------------------------------------------------
//	Class:	X2Effect_ConditionalSetUnitValue
//	Author: Musashi
//	
//-----------------------------------------------------------
class X2Effect_ConditionalSetUnitValue extends XMBEffect_ConditionalBonus;

var name UnitName;
var float NewValueToSet;
var EUnitValueCleanup CleanupType;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnitState;
	
	//`LOG(default.class @ GetFuncName() @ UnitName @ NewValueToSet,, 'RPG');

	TargetUnitState = XComGameState_Unit(kNewTargetState);
	TargetUnitState.SetUnitFloatValue(UnitName, NewValueToSet, CleanupType);
}

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	if (ValidateAttack(EffectState, Attacker, Target, AbilityState) == 'AA_Success')
	{
		//`LOG(default.class @ GetFuncName() @ UnitName @ NewValueToSet,, 'RPG');
		Attacker.SetUnitFloatValue(UnitName, NewValueToSet, CleanupType);
	}
	else
	{
		//`LOG(default.class @ GetFuncName() @ UnitName @ 0,, 'RPG');
		Attacker.SetUnitFloatValue(UnitName, 0, CleanupType);
	}
}
