class X2Effect_BlueMoveSlash extends X2Effect_Persistent;

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Ability AbilityState;
	local UnitValue BlueMoveSlashUnitValue;

	SourceUnit.GetUnitValue('BlueMoveSlash', BlueMoveSlashUnitValue);

	if(BlueMoveSlashUnitValue.fValue >= 1)
		return false;

	if (AbilityContext.InputContext.MovementPaths[0].CostIncreases.Length == 0)
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
		if (AbilityState != none)
		{
			SourceUnit.ActionPoints.Length = 0;
			SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
			SourceUnit.SetUnitFloatValue('BlueMoveSlash', BlueMoveSlashUnitValue.fValue + 1, eCleanup_BeginTurn);
			return true;
		}
	}
	return false;
}
