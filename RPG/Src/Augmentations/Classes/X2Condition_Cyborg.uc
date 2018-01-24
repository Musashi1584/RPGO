class X2Condition_Cyborg extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget)
{ 
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kTarget);

	if (IsCyborg(TargetUnit))
	{
		return 'AA_Success';
	}

	return 'AA_NoCyborg';
}

static function bool IsCyborg(XComGameState_Unit TargetUnit)
{
	local EInventorySlot InvSlot;

	foreach class'X2Item_Augmentations'.default.AugmentationSlots(InvSlot)
	{
		If (TargetUnit.GetItemInSlot(InvSlot) == none)
		{
			return false;
		}
	}

	return true;
}
