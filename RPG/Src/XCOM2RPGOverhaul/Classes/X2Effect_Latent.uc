class X2Effect_Latent extends X2Effect;

protected simulated function OnEffectAdded (const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit UnitState;

	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);

	UnitState = XComGameState_Unit(kNewTargetState);
	if (UnitState != none)
	{
		UnitState.bRolledForPsiGift = false;
	}
}