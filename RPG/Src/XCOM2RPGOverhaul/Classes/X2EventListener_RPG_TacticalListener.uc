class X2EventListener_RPG_TacticalListener extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate());
	Templates.AddItem(CreateListenerTemplate_OnCleanupTacticalMission());

	return Templates;
}

static function CHEventListenerTemplate CreateListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGScamperStartListener');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = false;

	Template.AddCHEvent('ScamperBegin', OnScamperBegin, ELD_OnStateSubmitted);
	`LOG("Register Event OnScamperBegin",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnCleanupTacticalMission()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGCleanupTacticalMission');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = false;

	Template.AddCHEvent('CleanupTacticalMission', OnCleanupTacticalMission, ELD_OnStateSubmitted);
	`LOG("Register Event CleanupTacticalMission",, 'RPG');

	return Template;
}

static function EventListenerReturn OnScamperBegin(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComTacticalGRI TacticalGRI;
	local XGBattle_SP Battle;
	local XGPlayer HumanPlayer;
	local XComGameState_AIGroup GroupState;
	local XComGameState_Unit TargetUnit, SourceUnit, ChainStartTarget;
	local XComGameStateContext_RevealAI RevealAIContext;
	local XComGameState_Ability AbilityState;
	local XComGameStateHistory History;
	local int ChainStartIndex;
	local Name EffectName, Result;
	local array<int> MemberIDs;
	local array<XComGameState_Unit> PlayerUnits;
	local array<XComGameState_Unit> LivingMemberStates;

	RevealAIContext = XComGameStateContext_RevealAI(GameState.GetContext());
	`LOG(GetFuncName() @ RevealAIContext.SummaryString());

	if (RevealAIContext == none)
		return ELR_NoInterrupt;


	TacticalGRI = `TACTICALGRI;
	Battle = (TacticalGRI != none)? XGBattle_SP(TacticalGRI.m_kBattle) : none;
	if(Battle != none)
	{
		HumanPlayer = Battle.GetHumanPlayer();
		HumanPlayer.GetUnits(PlayerUnits, true, true, false);

		foreach PlayerUnits(SourceUnit)
		{
			AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(SourceUnit.FindAbility('TriggerHappyScamperShot').ObjectID));

			if (AbilityState == none)
				continue;

			GroupState = XComGameState_AIGroup(EventData);
			GroupState.GetLivingMembers(MemberIDs, LivingMemberStates);

			`LOG(GetFuncName() @ SourceUnit.GetFullName() @ "try to trigger against" @ LivingMemberStates.Length @ "Enemies",, 'RPG');

			foreach LivingMemberStates(TargetUnit)
			{
				Result = AbilityState.CanActivateAbilityForObserverEvent(TargetUnit, SourceUnit);
				if (Result == 'AA_Success')
				{
					// Check effects on target unit at the start of this chain.
					History = `XCOMHISTORY;
					ChainStartIndex = History.GetEventChainStartIndex();
					if (ChainStartIndex != INDEX_NONE)
					{
						ChainStartTarget = XComGameState_Unit(History.GetGameStateForObjectID(TargetUnit.ObjectID, , ChainStartIndex));
						foreach class'X2Ability_DefaultAbilitySet'.default.OverwatchExcludeEffects(EffectName)
						{
							if (ChainStartTarget.IsUnitAffectedByEffectName(EffectName))
							{
								continue;
							}
						}
					}
					`LOG(GetFuncName() @ "AbilityTriggerAgainstSingleTarget" @ TargetUnit.SummaryString(),, 'RPG');
					//SourceUnit.ActionPoints.AddItem('TriggerHappyActionPoint');
					AbilityState.AbilityTriggerAgainstSingleTarget(TargetUnit.GetReference(), false);
				}
				else
				{
					`LOG(GetFuncName() @ SourceUnit.GetFullName() @ "CanActivateAbilityForObserverEvent" @ Result,, 'RPG');
				}
			}
		}
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnCleanupTacticalMission(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_BattleData BattleData;
	local XComGameState_Unit Unit;
	local XComGameStateHistory History;
	local XComGameState_Effect EffectState;
	local StateObjectReference EffectRef;

    History = `XCOMHISTORY;
    BattleData = XComGameState_BattleData(EventData);
    BattleData = XComGameState_BattleData(GameState.GetGameStateForObjectID(BattleData.ObjectID));

	foreach History.IterateByClassType(class'XComGameState_Unit', Unit)
	{
		if(Unit.IsAlive() && !Unit.bCaptured)
		{
			foreach Unit.AffectedByEffects(EffectRef)
			{
				EffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
				if (EffectState.GetX2Effect().EffectName == class'X2Effect_ReducedRecoveryTime'.default.EffectName)
				{
					X2Effect_ReducedRecoveryTime(EffectState.GetX2Effect()).ApplyFieldSurgeon(EffectState, Unit, GameState);
				}
			}
		}
	}

	return ELR_NoInterrupt;
}

