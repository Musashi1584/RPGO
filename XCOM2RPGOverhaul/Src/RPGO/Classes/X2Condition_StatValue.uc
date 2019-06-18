class X2Condition_StatValue extends X2Condition;

struct StatVal
{
	var ECharStatType	StatType;
	var float			StatValue;
};

var array<StatVal> StatValues;

function AddStatValue(ECharStatType StatType, float StatValue)
{
	local StatVal NewStatVal;
	
	NewStatVal.StatType = StatType;
	NewStatVal.StatValue = StatValue;
	StatValues.AddItem(NewStatVal);
}

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit UnitState;
	local StatVal ThisStatVal;

	UnitState = XComGameState_Unit(kTarget);
	
	if (UnitState == none)
		return 'AA_NotAUnit';
	
	foreach StatValues(ThisStatVal)
	{
		`LOG(default.class @ GetFuncName() @ ThisStatVal.StatType @ UnitState.GetCurrentStat(ThisStatVal.StatType) @ ThisStatVal.StatValue,, 'RPG');
		if (UnitState.GetCurrentStat(ThisStatVal.StatType) <= ThisStatVal.StatValue)
		{
			return 'AA_StatMatchFail';
		}
	}

	return 'AA_Success'; 
}