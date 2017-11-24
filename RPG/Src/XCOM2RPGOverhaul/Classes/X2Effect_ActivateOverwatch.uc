class X2Effect_ActivateOverwatch extends X2Effect_Persistent config(RPG);

var config array<name> OverwatchAbilities;
var name UnitValueName;

var private name EventName;

static private function TriggerAssociatedEvent(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState)
{
	local XComGameState_Unit SourceUnit, TargetUnit;
	local XComGameStateHistory History;
	local X2EventManager EventManager;

	`Log(string(GetFuncName()));

	History = `XCOMHISTORY;
	SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	TargetUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	EventManager = `XEVENTMGR;
	EventManager.TriggerEvent(default.EventName, TargetUnit, SourceUnit);
}

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local XComGameState_Unit UnitState;
	local X2EventManager EventMgr;
	local XMBGameState_EventProxy Proxy;
	local XComGameState NewGameState;
	local Object ListenerObj;

	`Log(string(GetFuncName()));

	EventMgr = `XEVENTMGR;

	NewGameState = EffectGameState.GetParentGameState();
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	Proxy = class'XMBGameState_EventProxy'.static.CreateProxy(EffectGameState, NewGameState);
	
	ListenerObj = Proxy;

	// Register for the required event
	Proxy.OnEvent = EventHandler;
	Proxy.bTriggerOnceOnly = true;
	EventMgr.RegisterForEvent(ListenerObj, default.EventName, class'XMBGameState_EventProxy'.static.EventHandler, ELD_OnStateSubmitted,, UnitState);	
}

static function EventListenerReturn EventHandler(XComGameState_BaseObject SourceState, Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameStateHistory History;
	local XComGameState_Unit UnitState;
	local XComGameState_Ability AbilityState, OverwatchState;
	local X2Effect_ActivateOverwatch EffectTemplate;
	local XComGameState_Effect EffectState;
	local StateObjectReference OverwatchRef;
	local XComGameState NewGameState;
	local name AbilityName;

	`Log(string(GetFuncName()));

	History = `XCOMHISTORY;

	EffectState = XComGameState_Effect(SourceState);
	if (EffectState == none)
		return ELR_NoInterrupt;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));

	EffectTemplate = X2Effect_ActivateOverwatch(EffectState.GetX2Effect());

	foreach EffectTemplate.OverwatchAbilities(AbilityName)
	{
		OverwatchRef = UnitState.FindAbility(AbilityName);
		if (OverwatchRef.ObjectID == 0)
			continue;

		OverwatchState = XComGameState_Ability(History.GetGameStateForObjectID(OverwatchRef.ObjectID));
		if (AbilityState.SourceWeapon.ObjectID != 0 && AbilityState.SourceWeapon != OverwatchState.SourceWeapon)
			continue;

		// Found an overwatch ability. First, make a couple of changes before we activate the ability.

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
		UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));

		while (UnitState.NumActionPoints() < 2)
		{
			//  give the unit an action point so they can activate overwatch										
			UnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);					
		}
		if (EffectTemplate.UnitValueName != '')
			UnitState.SetUnitFloatValue(EffectTemplate.UnitValueName, 1, eCleanup_BeginTurn);

		NewGameState.AddStateObject(UnitState);
		`TACTICALRULES.SubmitGameState(NewGameState);

		// Now activate the overwatch ability.

		OverwatchState.AbilityTriggerAgainstSingleTarget(UnitState.GetReference(), false);
		return ELR_NoInterrupt;
	}

	// No ability found
	return ELR_NoInterrupt;
}

defaultproperties
{
	EffectAddedFn=TriggerAssociatedEvent
	EventName="TriggerOverwatchAbility"
}