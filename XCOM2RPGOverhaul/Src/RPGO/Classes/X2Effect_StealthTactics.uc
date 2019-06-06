class X2Effect_StealthTactics extends X2Effect_Persistent;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{;
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(kNewTargetState);

	if (UnitState != none && !UnitState.IsConcealed())
	{
		`XEVENTMGR.TriggerEvent('EffectEnterUnitConcealment', UnitState, UnitState, NewGameState);
	}
}