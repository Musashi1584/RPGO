class X2AbilityCost_ActionPointsExtended extends X2AbilityCost_ActionPoints;

var() array<name> FreeCostEffects;
var() array<name> FreeCostAbilities;

simulated function ApplyCost(XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_BaseObject AffectState, XComGameState_Item AffectWeapon, XComGameState NewGameState)
{
	local int i;
	//Start Patch
	for (i = 0; i < FreeCostEffects.Length; ++i)
	{
		if (XComGameState_Unit(AffectState).IsUnitAffectedByEffectName(FreeCostEffects[i]))
			return;
	}
	for (i = 0; i < FreeCostAbilities.Length; ++i)
	{
		if (XComGameState_Unit(AffectState).HasSoldierAbility(FreeCostAbilities[i]))
			return;
	}
	//End Patch
	super.ApplyCost(AbilityContext, kAbility, AffectState, AffectWeapon, NewGameState);
}

