class X2Condition_Fade extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(kTarget);

	if (UnitState == none)
		return 'AA_NotAUnit';

	if (UnitState.IsConcealed())
		return 'AA_UnitIsConcealed';

	if (class 'X2TacticalVisibilityHelpers'.static.GetNumVisibleEnemyTargetsToSource(kTarget.ObjectID) > 0)
		return 'AA_StillSpotted';

	return 'AA_Success';
}