class X2Effect_MaybeApplyDirectionalWorldDamage extends X2Effect_ApplyDirectionalWorldDamage;

simulated function ApplyDirectionalDamageToTarget(XComGameState_Unit SourceUnit, XComGameState_Unit TargetUnit, XComGameState NewGameState)
{
	if (`SYNC_RAND(100) < ApplyChance)
		super.ApplyDirectionalDamageToTarget(SourceUnit, TargetUnit, NewGameState);
}