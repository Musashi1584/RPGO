class X2Condition_NotFlankable extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kTarget);

	if (!TargetUnit.GetMyTemplate().bCanTakeCover)
		return 'AA_Success';

	return 'AA_InvalidTarget';
}