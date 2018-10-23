class X2Effect_BlueMoveSlash extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager			EventMgr;
	local XComGameState_Unit		UnitState;
	local Object					EffectObj;

	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	EventMgr.RegisterForEvent(EffectObj, 'BlueMoveSlash', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Ability AbilityState;
	local UnitValue BlueMoveSlashUnitValue;
	local UnitValue ReaperUnitValue;

	SourceUnit.GetUnitValue('BlueMoveSlash', BlueMoveSlashUnitValue);

	if(BlueMoveSlashUnitValue.fValue >= 1)
		return false;

	if (SourceUnit.IsUnitAffectedByEffectName(class'X2Effect_Serial'.default.EffectName))
		return false;

	if (SourceUnit.GetUnitValue('Reaper_SuperKillCheck', ReaperUnitValue) && ReaperUnitValue.fValue == 1)
		return false;

	if (PreCostActionPoints.Find('RunAndGun') != INDEX_NONE)
		return false;

	if (PreCostActionPoints.Length == 2 && AbilityContext.InputContext.MovementPaths[0].CostIncreases.Length == 0)
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
		`LOG(self.Class.Name @ GetFuncName() @ AbilityState.GetMyTemplateName() @ AbilityState.IsMeleeAbility(),, 'RPG');
		
		if (AbilityState != none && AbilityState.IsMeleeAbility())
		{
			SourceUnit.ActionPoints.Length = 0;
			SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
			SourceUnit.SetUnitFloatValue('BlueMoveSlash', BlueMoveSlashUnitValue.fValue + 1, eCleanup_BeginTurn);

			AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			
			`LOG(self.Class.Name @ GetFuncName() @ AbilityState.GetMyTemplateName() @ AbilityState.IsMeleeAbility(),, 'RPG');

			`XEVENTMGR.TriggerEvent('BlueMoveSlash', AbilityState, SourceUnit, NewGameState);
			return true;
		}
	}
	return false;
}
