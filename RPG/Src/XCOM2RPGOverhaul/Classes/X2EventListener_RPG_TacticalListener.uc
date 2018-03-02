class X2EventListener_RPG_TacticalListener extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplateScamperBegin());
	Templates.AddItem(CreateListenerTemplateOnCleanupTacticalMission());
	Templates.AddItem(CreateListenerTemplateGetItemRange());
	Templates.AddItem(CreateListenerTemplateFailsafe());

	return Templates;
}

static function CHEventListenerTemplate CreateListenerTemplateScamperBegin()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGScamperStartListener');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = false;

	Template.AddCHEvent('ScamperBegin', OnScamperBegin, ELD_OnStateSubmitted);
	`LOG("Register Event OnScamperBegin",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplateOnCleanupTacticalMission()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGCleanupTacticalMission');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = false;

	Template.AddCHEvent('CleanupTacticalMission', OnCleanupTacticalMission, ELD_OnStateSubmitted);
	`LOG("Register Event CleanupTacticalMission",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplateGetItemRange()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGGetItemRange');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = false;

	Template.AddCHEvent('OnGetItemRange', OnGetItemRangeBombard, ELD_OnStateSubmitted);
	`LOG("Register Event OnGetItemRangeBombard",, 'RPG');

	Template.AddCHEvent('OnGetItemRange', OnGetItemRangeScout, ELD_OnStateSubmitted);
	`LOG("Register Event OnGetItemRangeScout",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplateFailsafe()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGPreAcquiredHackReward');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = false;

	Template.AddCHEvent('PreAcquiredHackReward', OnPreAcquiredHackReward, ELD_OnStateSubmitted);
	`LOG("Register Event PreAcquiredHackReward",, 'RPG');

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

static function EventListenerReturn OnGetItemRangeBombard(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple				OverrideTuple;
	local XComGameState_Item		Item;
	//local int						Range;  // in tiles -- either bonus or override
	local XComGameState_Ability		Ability;
	//local bool						bOverride; // if true, replace the range, if false, just add to it
	local XComGameState_Item		SourceWeapon;
	local X2WeaponTemplate			WeaponTemplate;
	local XComGameState_Unit		UnitState;

	OverrideTuple = XComLWTuple(EventData);
	if(OverrideTuple == none)
	{
		`REDSCREEN("OnGetItemRangeBombard event triggered with invalid event data.");
		return ELR_NoInterrupt;
	}

	Item = XComGameState_Item(EventSource);
	if(Item == none)
		return ELR_NoInterrupt;

	if(OverrideTuple.Id != 'GetItemRange')
		return ELR_NoInterrupt;

	Ability = XComGameState_Ability(OverrideTuple.Data[2].o);  // optional ability

	//verify the owner has bombard
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Item.OwnerStateObject.ObjectID));
	if(!UnitState.HasSoldierAbility('RpgBombard'))
		return ELR_NoInterrupt;

	if(Ability == none)
		return ELR_NoInterrupt;

	//get the source weapon and weapon template
	SourceWeapon = Ability.GetSourceWeapon();
	WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
	
	if(WeaponTemplate == none)
		return ELR_NoInterrupt;

	// make sure the weapon is either a grenade or a grenade launcher
	if(X2GrenadeTemplate(WeaponTemplate) != none || X2GrenadeLauncherTemplate(WeaponTemplate) != none || WeaponTemplate.DataName == 'Battlescanner')
	{
		OverrideTuple.Data[1].i += class'X2Ability_LongWar'.default.BOMBARD_BONUS_RANGE_TILES;
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnGetItemRangeScout(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple				OverrideTuple;
	local XComGameState_Item		Item;
	//local int						Range;  // in tiles -- either bonus or override
	local XComGameState_Ability		Ability;
	//local bool						bOverride; // if true, replace the range, if false, just add to it
	local XComGameState_Item		SourceWeapon;
	local X2WeaponTemplate			WeaponTemplate;
	local XComGameState_Unit		UnitState;

	OverrideTuple = XComLWTuple(EventData);
	if(OverrideTuple == none)
	{
		`REDSCREEN("OnGetItemRangeScout event triggered with invalid event data.");
		return ELR_NoInterrupt;
	}

	Item = XComGameState_Item(EventSource);
	if(Item == none)
		return ELR_NoInterrupt;

	if(OverrideTuple.Id != 'GetItemRange')
		return ELR_NoInterrupt;

	Ability = XComGameState_Ability(OverrideTuple.Data[2].o);  // optional ability

	//verify the owner has bombard
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(Item.OwnerStateObject.ObjectID));
	if(!UnitState.HasSoldierAbility('Scout'))
		return ELR_NoInterrupt;

	if(Ability == none)
		return ELR_NoInterrupt;

	//get the source weapon and weapon template
	SourceWeapon = Ability.GetSourceWeapon();
	WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
	
	if(WeaponTemplate == none)
		return ELR_NoInterrupt;

	// make sure the weapon is battlescanner
	if(WeaponTemplate.DataName == 'Battlescanner')
	{
		OverrideTuple.Data[1].i *= class'X2Ability_RPGOverhaul'.default.SCOUT_BATTLESCANNER_RANGE_SCALAR;
	}

	return ELR_NoInterrupt;
}


static function EventListenerReturn OnPreAcquiredHackReward(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple				OverrideHackRewardTuple;
	local XComGameState_Unit		Hacker;
	local XComGameState_BaseObject	HackTarget;
	local X2HackRewardTemplate		HackTemplate;
	local XComGameState_Ability		AbilityState;
	local StateObjectReference		AbilityRef;

	OverrideHackRewardTuple = XComLWTuple(EventData);
	if(OverrideHackRewardTuple == none)
	{
		`REDSCREEN("OnPreAcquiredHackReward event triggered with invalid event data.");
		return ELR_NoInterrupt;
	}

	HackTemplate = X2HackRewardTemplate(EventSource);
	if(HackTemplate == none)
		return ELR_NoInterrupt;

	if(OverrideHackRewardTuple.Id != 'OverrideHackRewards')
		return ELR_NoInterrupt;

	Hacker = XComGameState_Unit(OverrideHackRewardTuple.Data[1].o);
	HackTarget = XComGameState_BaseObject(OverrideHackRewardTuple.Data[2].o); // not necessarily a unit, could be a Hackable environmental object

	if(Hacker == none || HackTarget == none)
		return ELR_NoInterrupt;

	if(Hacker == none || !Hacker.HasSoldierAbility('Failsafe'))
		return ELR_NoInterrupt;

	if(HackTemplate.bBadThing)
	{
		if(Rand(100) < class'X2Ability_LongWar'.default.FAILSAFE_PCT_CHANCE)
		{
			OverrideHackRewardTuple.Data[0].b = true;
			//AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(GetOwningEffect().ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
			AbilityRef = Hacker.FindAbility('Failsafe');
			if(AbilityRef.ObjectID > 0)
			{
				AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityRef.ObjectID));
				`XEVENTMGR.TriggerEvent('FailsafeTriggered', AbilityState, Hacker, GameState);
			}
		}
	}

	return ELR_NoInterrupt;
}