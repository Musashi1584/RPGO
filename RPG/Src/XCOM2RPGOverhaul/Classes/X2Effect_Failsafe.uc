class X2Effect_Failsafe extends X2Effect_Persistent;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local X2EventManager EventMgr;
	local Object								EffectObj;
	local XComGameState_Unit					UnitState;

	EventMgr = `XEVENTMGR;
	EffectObj = NewEffectState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(NewEffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	EventMgr.RegisterForEvent(EffectObj, 'FailsafeTriggered', NewEffectState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

defaultproperties
{
    DuplicateResponse=eDupe_Ignore
	EffectName="Failsafe";
	bRemoveWhenSourceDies=true;
}