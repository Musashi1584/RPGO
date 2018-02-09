class X2Effect_CloseEncounters extends X2Effect_Persistent config (RPG);

var config int CE_USES_PER_TURN;
var config array<name> CE_ABILITYNAMES;
var config int CE_MAX_TILES;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager			EventMgr;
	local XComGameState_Unit		UnitState;
	local Object					EffectObj;

	EventMgr = `XEVENTMGR;
	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	EventMgr.RegisterForEvent(EffectObj, 'CloseEncounters', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameState_Ability					AbilityState;
	local XComGameState_Unit					TargetUnit;
	local UnitValue								CEUsesThisTurn;
	local int									iUsesThisTurn;
	local bool									bLog;

	bLog = false;

	if (SourceUnit.IsUnitAffectedByEffectName(class'X2Effect_Serial'.default.EffectName))
	{
		`LOG(self.Class.Name @ GetFuncName() @ class'X2Effect_Serial'.default.EffectName, bLog, 'RPG');
		return false;
	}

	if (SourceUnit.IsUnitAffectedByEffectName(class'X2Effect_DeathfromAbove'.default.EffectName))
	{
		`LOG(self.Class.Name @ GetFuncName() @ class'X2Effect_DeathfromAbove'.default.EffectName, bLog, 'RPG');
		return false;
	}

	if (PreCostActionPoints.Find('RunAndGun') != -1)
	{
		`LOG(self.Class.Name @ GetFuncName() @ "RunAndGun", bLog, 'RPG');
		return false;
	}

	if (kAbility == none)
	{
		`LOG(self.Class.Name @ GetFuncName() @ "kAbility", bLog, 'RPG');
		return false;
	}
	//if (kAbility.SourceWeapon != EffectState.ApplyEffectParameters.ItemStateObjectRef)
	//{
	//	`LOG(self.Class.Name @ GetFuncName() @ "kAbility.SourceWeapon" @ kAbility.SourceWeapon.ObjectID @ EffectState.ApplyEffectParameters.ItemStateObjectRef.ObjectID,, 'RPG');
	//	return false;
	//}

	SourceUnit.GetUnitValue ('CloseEncountersUses', CEUsesThisTurn);
	iUsesThisTurn = int(CEUsesThisTurn.fValue);

	if (iUsesThisTurn >= default.CE_USES_PER_TURN)
	{
		`LOG(self.Class.Name @ GetFuncName() @ "iUsesThisTurn", bLog, 'RPG');
		return false;
	}

	TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));  	

	if (TargetUnit == none)
	{
		`LOG(self.Class.Name @ GetFuncName() @ "TargetUnit", bLog, 'RPG');
		return false;
	}

	if (SourceUnit.TileDistanceBetween(TargetUnit) > default.CE_MAX_TILES + 1)
	{
		`LOG(self.Class.Name @ GetFuncName() @ "TileDistanceBetween", bLog, 'RPG');
		return false;
	}

	if (XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID)) == none)
	{
		`LOG(self.Class.Name @ GetFuncName() @ "XComGameState_Ability", bLog, 'RPG');
		return false;
	}

	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));

	if (AbilityState != none)
	{
		if (default.CE_ABILITYNAMES.Find(kAbility.GetMyTemplateName()) != -1)
		{
			if (SourceUnit.NumActionPoints() < 2 && PreCostActionPoints.Length > 0)
			{
				`LOG(self.Class.Name @ GetFuncName() @ "TRIGGER ABILITY", bLog, 'RPG');
				SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
				SourceUnit.SetUnitFloatValue ('CloseEncountersUses', iUsesThisTurn + 1.0, eCleanup_BeginTurn);
				`XEVENTMGR.TriggerEvent('CloseEncounters', AbilityState, SourceUnit, NewGameState);
			}
		}
	}
	return false;
}