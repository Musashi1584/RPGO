class X2Condition_TargetAutopsy extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{ 
	local XComGameState_Unit TargetUnit;
	local name AutopsyName;

	TargetUnit = XComGameState_Unit(kTarget);

	switch (TargetUnit.GetMyTemplate().CharacterGroupName)
	{
		case 'AdventCaptain':
			AutopsyName = 'AutopsyAdventOfficer';
			break;
		default:
			AutopsyName = name("Autopsy" $ TargetUnit.GetMyTemplate().CharacterGroupName);
			break;
	}

	if (HasAutopsy(AutopsyName))
	{
		return 'AA_Success';
	}

	return 'AA_NoAutopsy';
}

static function bool HasAutopsy(name Autopsy)
{
	return class'UIUtilities_Strategy'.static.GetXComHQ().IsTechResearched(Autopsy);
	//local XComGameStateHistory History;
	//local XComGameState_Tech TechState;
	//local array<StateObjectReference> TechRefs;
	//local int idx;
	//
	//TechRefs = class'UIUtilities_Strategy'.static.GetXComHQ().GetCompletedResearchTechs();
	//
	//History = `XCOMHISTORY;
	//for (idx = 0; idx < TechRefs.length; idx++)
	//{
	//	TechState = XComGameState_Tech(History.GetGameStateForObjectID(TechRefs[idx].ObjectID));
	//	if (TechState.GetMyTemplateName() == Autopsy)
	//		return true;
	//}
	//return false;
}
