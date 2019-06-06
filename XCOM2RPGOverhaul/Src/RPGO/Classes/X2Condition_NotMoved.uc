class X2Condition_NotMoved extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit UnitState;
	local UnitValue MovesThisTurn;

	UnitState = XComGameState_Unit(kTarget);
	
	if (UnitState == none)
		return 'AA_NotAUnit';
	
	if (UnitState.GetUnitValue('MovesThisTurn', MovesThisTurn) && MovesThisTurn.fValue > 0)
	{
		return 'AA_HasMoved';
	}

	return 'AA_Success'; 
}