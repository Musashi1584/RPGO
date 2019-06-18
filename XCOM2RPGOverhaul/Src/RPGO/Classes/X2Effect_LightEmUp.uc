class X2Effect_LightEmUp extends X2Effect_Persistent;

var name LightEmUpActionPoint;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager			EventMgr;
	local XComGameState_Unit		UnitState;
	local Object					EffectObj;

	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	EventMgr.RegisterForEvent(EffectObj, 'LightEmUp', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Ability					AbilityState;
	local XComGameState_Unit					TargetUnit;

	//  if under the effect of Serial, let that handle restoring the full action cost - will this work?
	if (SourceUnit.IsUnitAffectedByEffectName(class'X2Effect_Serial'.default.EffectName))
		return false;

	if (PreCostActionPoints.Find('RunAndGun') != INDEX_NONE)
		return false;

	TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	if (TargetUnit.IsDead() &&
		TargetUnit.GetMyTemplate().CharacterGroupName == 'TheLost' &&
		class'X2Effect_TheLostHeadshot'.default.ValidHeadshotAbilities.Find(AbilityContext.InputContext.AbilityTemplateName) != INDEX_NONE
	)
	{
		return false;
	}

	//`LOG(default.Class @ GetFuncName() @ SourceUnit.GetFullName() @ SourceUnit.ActionPoints.Length @ SourceUnit.NumActionPoints() @ PreCostActionPoints.Length,, 'RPG');

	if (PreCostActionPoints.Length == 2)
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));

		if (AbilityState != none && AbilityState.GetMyTemplateName() == 'StandardShot')
		{
			SourceUnit.ActionPoints.Length = 0;
			SourceUnit.ActionPoints.AddItem(default.LightEmUpActionPoint);

			// Get the AbilityState for LightEmUp so we dont trigger the flyover for StandardShot
			AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			`XEVENTMGR.TriggerEvent('LightEmUp', AbilityState, SourceUnit, NewGameState);

			return true;
		}
	}
	return false;
}


defaultproperties
{
	LightEmUpActionPoint = "LightEmUp"
}