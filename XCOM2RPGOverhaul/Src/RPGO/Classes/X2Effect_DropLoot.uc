class X2Effect_DropLoot extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit Unit;

	`Log("Running DropLoot");

	Unit = XComGameState_Unit(kNewTargetState);
	if (Unit == none)
	{
		`Log("DropLoot targeted a non-unit?");
		return;
	}

	Unit.RollForTimedLoot();
}