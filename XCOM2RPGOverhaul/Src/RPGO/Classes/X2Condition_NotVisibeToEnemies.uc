class X2Condition_NotVisibeToEnemies extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local int NumEnemyViewers;

	NumEnemyViewers = class'X2TacticalVisibilityHelpers'.static.GetNumEnemyViewersOfTarget(kTarget.ObjectID);

	//`LOG("Musashi: ConditionNotVisibeToEnemies NumEnemyViewers" @ NumEnemyViewers,, 'SpecOpsClass');

	if (NumEnemyViewers > 0)
		return 'AA_UnitIsVisibleToEnemies';

	return 'AA_Success'; 
}