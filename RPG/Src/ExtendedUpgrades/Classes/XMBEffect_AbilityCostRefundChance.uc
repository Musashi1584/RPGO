class XMBEffect_AbilityCostRefundChance extends X2Effect_Persistent implements(XMBEffectInterface);


///////////////////////
// Effect properties //
///////////////////////

var name TriggeredEvent;							// An event that will be triggered when this effect refunds an ability cost.
var bool bShowFlyOver;								// Show a flyover when this effect refunds an ability cost. Requires TriggeredEvent to be set.
var name CountValueName;							// Name of the unit value to use to count the number of actions refunded per turn.
var int MaxRefundsPerTurn;							// Maximum number of actions to refund per turn. Requires CountUnitValue to be set.
var bool bFreeCost;									// Make the ability usable without any action points if the conditions are met.
													// Not compatible with any conditions that depend on the target or result of the ability.
var int RefundChance;								// If greater zero make a roll on the RefundChance

//////////////////////////
// Condition properties //
//////////////////////////

var array<X2Condition> AbilityTargetConditions;		// Conditions on the target of the ability being refunded.
var array<X2Condition> AbilityShooterConditions;	// Conditions on the shooter of the ability being refunded.


////////////////////
// Implementation //
////////////////////

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	`LOG(Class.Name @ GetFuncName(),, 'ExtendedUpgrades');

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if (bShowFlyOver && TriggeredEvent != '')
		EventMgr.RegisterForEvent(EffectObj, TriggeredEvent, EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;
	local XComGameState_Unit TargetUnit;
	local UnitValue CountUnitValue;
	local int Roll;

	`LOG(Class.Name @ GetFuncName(),, 'ExtendedUpgrades');

	TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	if (TargetUnit == none)
		TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

	if (CountValueName != '')
	{
		SourceUnit.GetUnitValue(CountValueName, CountUnitValue);
		if (MaxRefundsPerTurn >= 0 && CountUnitValue.fValue >= MaxRefundsPerTurn)
			return false;
	}

	if (ValidateAttack(EffectState, SourceUnit, TargetUnit, kAbility) != 'AA_Success')
		return false;

	//  restore the pre cost action points to fully refund this action
	if (bFreeCost || SourceUnit.ActionPoints.Length != PreCostActionPoints.Length)
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
		if (AbilityState != none)
		{
			SourceUnit.ActionPoints = PreCostActionPoints;
			`LOG(String(Class.Name) @ "PostAbilityCostPaid" @ AbilityState.GetMyTemplateName() @ SourceUnit.ActionPoints.Length,, 'ExtendedUpgrades');

			Roll = `SYNC_RAND(100);
			if (RefundChance > 0 && Roll > RefundChance)
			{
				`LOG("XMBEffect_AbilityCostRefundChance failed. Chance" @ RefundChance @ "Rolled" @ Roll,, 'ExtendedUpgrades');
				return false;
			}

			if (CountValueName != '')
			{
				SourceUnit.SetUnitFloatValue(CountValueName, CountUnitValue.fValue + 1, eCleanup_BeginTurn);
			}

			if (TriggeredEvent != '')
			{
				EventMgr = `XEVENTMGR;
				EventMgr.TriggerEvent(TriggeredEvent, AbilityState, SourceUnit, NewGameState);
			}

			return true;
		}
	}

	return false;
}

function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local name AvailableCode;

	AvailableCode = class'XMBEffectUtilities'.static.CheckTargetConditions(AbilityTargetConditions, EffectState, Attacker, Target, AbilityState);
	`LOG(Class.Name @ GetFuncName() @ AvailableCode @ AbilityState.GetMyTemplateName(),, 'ExtendedUpgrades');
	if (AvailableCode != 'AA_Success')
		return AvailableCode;
		
	AvailableCode = class'XMBEffectUtilities'.static.CheckShooterConditions(AbilityShooterConditions, EffectState, Attacker, Target, AbilityState);
	if (AvailableCode != 'AA_Success')
		return AvailableCode;
		
	return 'AA_Success';
}

////////////////////////
// XMBEffectInterface //
////////////////////////

function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue);
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, optional ShotBreakdown ShotBreakdown, optional out array<ShotModifierInfo> ShotModifiers);

function bool GetExtValue(LWTuple Data)
{
	local XComGameState_Unit SourceUnit;
	local XComGameState_Ability AbilityState;
	local XComGameState_Effect EffectState;
	local UnitValue CountUnitValue;

	if (bFreeCost)
	{
		if (Data.Id == 'GetActionPointCost')
		{
			SourceUnit = XComGameState_Unit(Data.Data[0].o);
			AbilityState = XComGameState_Ability(Data.Data[1].o);
			EffectState = XComGameState_Effect(Data.Data[2].o);

			if (CountValueName != '')
			{
				SourceUnit.GetUnitValue(CountValueName, CountUnitValue);
				if (MaxRefundsPerTurn >= 0 && CountUnitValue.fValue >= MaxRefundsPerTurn)
					return false;
			}

			if (ValidateAttack(EffectState, SourceUnit, none, AbilityState) == 'AA_Success')
			{
				Data.Data[3].i = 0;
				return true;
			}
		}
	}

	return false;
}

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	bShowFlyOver = true
	MaxRefundsPerTurn = -1;
}