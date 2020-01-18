class X2Effect_QuickFeet extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager		EventMgr;
	local XComGameState_Unit	UnitState;
	local Object				EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	EventMgr.RegisterForEvent(EffectObj, 'Relocation', EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
	EventMgr.RegisterForEvent(EffectObj, 'UnitConcealmentBroken', Relocation_Listener, ELD_OnStateSubmitted,, UnitState,, EffectGameState);
}

//	Handles the case of Concealment being broken by this Unit activating an ability.
static function EventListenerReturn Relocation_Listener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit	UnitState;
	local XComGameState_Player	PlayerState;
	local XComGameState			NewGameState;
	local X2EventManager		EventMgr;
	local XComGameState_Ability AbilityStateQuickFeet;
	local XComGameState_Effect	EffectGameState;
	local XComGameStateHistory	History;

	UnitState = XComGameState_Unit(EventSource);
	EffectGameState = XComGameState_Effect(CallbackData);

	if (UnitState != none && EffectGameState != none)
	{	
		//`LOG("Concealment broken for unit: " @ UnitState.GetFullName() @ UnitState.ObjectID @ "by unit: " @ UnitState.ConcealmentBrokenByUnitRef.ObjectID,, 'RPG');
		History = `XCOMHISTORY;
		PlayerState = XComGameState_Player(History.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.PlayerStateObjectRef.ObjectID));

		//	It is current tactical turn of the player whose unit has applied the Relocation persistent effect, AND
		//	Concealment was not broken by an enemy sighting this unit.
		//	I have checked, if the unit breaks concealment by shooting, the ConcealmentBrokenByUnitRef remains at -1.
		if (PlayerState != none && `TACTICALRULES.GetUnitActionTeam() == PlayerState.GetTeam() && UnitState.ConcealmentBrokenByUnitRef.ObjectID == -1)	
		{
			//	Grant 1 Standard Action Point
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Relocation: Give AP");
			UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
			UnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
			`GAMERULES.SubmitGameState(NewGameState);

			//	Trigger Flyover
			AbilityStateQuickFeet = XComGameState_Ability(History.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			if (AbilityStateQuickFeet != none)
			{
				//`LOG("Triggering flyover",, 'RPG');
				EventMgr = `XEVENTMGR;
				EventMgr.TriggerEvent('Relocation', AbilityStateQuickFeet, UnitState, GameState);
			}
		}
	}
	return ELR_NoInterrupt;
}

//	Handle the cases where the concealment was broken by this unit moving into enemy field of vision, including melee abilities.
function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local XComGameStateHistory History;
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityStateQuickFeet;
	local int EventChainStartHistoryIndex;

	History = `XCOMHISTORY;
	EventChainStartHistoryIndex = History.GetEventChainStartIndex();

	//`LOG("X2Effect_QuickFeet Post Ability Cost Paid for:" @ SourceUnit.GetFullName() @ kAbility.GetMyTemplateName() @ ", EventChainStartHistoryIndex: " @ EventChainStartHistoryIndex,, 'RPG');

	if(SourceUnit.WasConcealed(EventChainStartHistoryIndex))
	{
		//`LOG("Unit was concealed at that time.",, 'RPG');

		if(!SourceUnit.IsConcealed())
		{
			//`LOG("Unit is not concealed now. Action Points: " @ SourceUnit.ActionPoints.Length @ "PreCost ActionPoints: " @ PreCostActionPoints.Length,, 'RPG');

			if (SourceUnit.ActionPoints.Length != PreCostActionPoints.Length)
			{
				//`LOG("All checks passed, giving AP and triggering flyover");

				SourceUnit.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);

				AbilityStateQuickFeet = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
				if (AbilityStateQuickFeet != none)
				{
					EventMgr = `XEVENTMGR;
					EventMgr.TriggerEvent('Relocation', AbilityStateQuickFeet, SourceUnit, NewGameState);
				}
				`LOG("X2Effect_QuickFeet AddActionPoint SourceUnit.IsConcealed()" @ SourceUnit.IsConcealed() @ SourceUnit.WasConcealed(EventChainStartHistoryIndex),, 'RPG');
				//	returning true STOPS the game from processing any other PostAbilityCostPaid, I don't believe this is what you intended here.
				return false;
			}
		}
	}

	return false;
}