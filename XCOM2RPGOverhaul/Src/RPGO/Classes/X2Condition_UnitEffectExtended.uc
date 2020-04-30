class X2Condition_UnitEffectExtended extends X2Condition;

// Variables to pass into the condition check:
var array<name>	ExcludingEffectNames;
var array<name>	RequiredEffectNames;
var bool		bRequireAll;			//»» True (default) makes the RequiredEffectNames array behave as an 'AND' statement. False makes it an 'OR' statement.
var bool		bCheckSourceUnit;		//»» Evaluate against the ability's SourceUnit instead of the TargetUnit (must be set for self-targeting AbilityShooterConditions - they dont pass a kTarget!)
var name		ExcludingErrorCode;		//»» Error code to use when an Excluded effect is present.
var name		RequiredErrorCode;		//»» Error code to use when Required effects are not present.


event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit	UnitState;
	local name					EffectName;
	local bool					bHasRequired;

	// Get the UnitState to evaluate against
	if (bCheckSourceUnit)
	{
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(kAbility.OwnerStateObject.ObjectID));
	}
	else
	{
		UnitState = XComGameState_Unit(kTarget);
	}

	// Check that the Unit has ONE or ALL Required Effects (depending on bRequireAll flag)
	if (RequiredEffectNames.Length > 0)
	{	
		bHasRequired = false;
		foreach RequiredEffectNames(EffectName)
		{
			if (UnitState.AffectedByEffectNames.Find(EffectName) != -1)
			{
				bHasRequired = true;

				if (bRequireAll) continue;
				else break;
			}
			else
			{
				if (bRequireAll)
				{
					bHasRequired = false;
					break;
		}	}	}

		if (!bHasRequired)
		{
			return RequiredErrorCode;
		}
	}


	// Check that the Unit has NO Excluding Effects 
	if (ExcludingEffectNames.Length > 0)
	{
		foreach ExcludingEffectNames(EffectName)
		{
			if (UnitState.AffectedByEffectNames.Find(EffectName) != -1)
			{
				return ExcludingErrorCode;
	}	}	}

	return 'AA_Success';
}


defaultproperties
{
	bRequireAll = true
	ExcludingErrorCode = "AA_HasAnExcludingEffect"
	RequiredErrorCode = "AA_MissingRequiredEffect"
}