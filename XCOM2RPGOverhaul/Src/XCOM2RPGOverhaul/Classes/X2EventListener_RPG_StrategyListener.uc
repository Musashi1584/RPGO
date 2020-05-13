class X2EventListener_RPG_StrategyListener extends X2EventListener dependson(X2SoldierClassTemplatePlugin) config (RPG);

struct RowDistribution
{
	var int Row;
	var int Count;
};


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate_AddAdditionialSquaddieAbilities());
	Templates.AddItem(CreateListenerTemplate_OnUnitRankUp());
	Templates.AddItem(CreateListenerTemplate_OnCompleteRespecSoldier());
	Templates.AddItem(CreateListenerTemplate_OnSoldierInfo());
	Templates.AddItem(CreateListenerTemplate_OnGetLocalizedCategory());
	Templates.AddItem(CreateListenerTemplate_OnSecondWaveChanged());

	//	Random Classes
	Templates.AddItem(CreateListenerTemplate_WeaponRestrictionsLoadout());

	return Templates;
}

static function CHEventListenerTemplate CreateListenerTemplate_AddAdditionialSquaddieAbilities()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGOSpecializationsAssigned');

	Template.RegisterInStrategy = true;

	Template.AddCHEvent('RPGOSpecializationsAssigned', AddAdditionialSquaddieAbilities, ELD_OnStateSubmitted);
	Template.AddCHEvent('PurchasedSoldierProgressionAbility', AddAdditionialSquaddieAbilities, ELD_OnStateSubmitted);

	`LOG(default.class @ "Register Event AddAdditionialSquaddieAbilities",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnUnitRankUp()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGUnitRankUpSecondWaveRoulette');

	Template.RegisterInStrategy = true;

	Template.AddCHEvent('UnitRankUp', AssignSoldierSpecializations, ELD_OnStateSubmitted);
	// compatibility with Commanders Choice Wotc
	Template.AddCHEvent('UnitRankUp', AssignSoldierSpecializations, ELD_Immediate);
	`LOG(default.class @ "Register Event AssignSoldierSpecializations",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnCompleteRespecSoldier()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGCompleteRespecSoldierSWTR');

	Template.RegisterInStrategy = true;

	Template.AddCHEvent('CompleteRespecSoldier', OnCompleteRespecSoldierSecondWave, ELD_OnStateSubmitted);
	`LOG(default.class @ "Register Event OnCompleteRespecSoldierSecondWave",, 'RPG');

	return Template;
}


static function CHEventListenerTemplate CreateListenerTemplate_OnSoldierInfo()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGSoldierInfo');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('SoldierClassIcon', OnSoldierInfo, ELD_Immediate);
	`LOG(default.class @ "Register Event SoldierClassIcon",, 'RPG');

	Template.AddCHEvent('SoldierClassDisplayName', OnSoldierInfo, ELD_Immediate);
	`LOG(default.class @ "Register Event SoldierClassDisplayName",, 'RPG');

	Template.AddCHEvent('SoldierClassSummary', OnSoldierInfo, ELD_Immediate);
	`LOG(default.class @ "Register Event SoldierClassSummary",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnGetLocalizedCategory()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGetLocalizedCategory');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('GetLocalizedCategory', OnGetLocalizedCategory, ELD_Immediate);
	`LOG(default.class @ "Register Event OnGetLocalizedCategory",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnSecondWaveChanged()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGOnSecondWaveChanged');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('OnSecondWaveChanged', OnSecondWaveChanged, ELD_OnStateSubmitted);
	`LOG(default.class @ "Register Event OnSecondWaveChanged",, 'RPG');

	return Template;
}

static function EventListenerReturn AddAdditionialSquaddieAbilities(Object EventData, Object EventSource, XComGameState GameState, Name EventName, Object CallbackData)
{
	local XComGameState_Unit UnitState;
	local XComGameState NewGameState;

	`LOG(default.class @ GetFuncName() @ "Eventlistener triggered:" @ EventName,, 'RPGO-Promotion');

	//if (!class'X2SecondWaveConfigOptions'.static.HasLimitedSpecializations())
	//{
	//	return ELR_NoInterrupt;
	//}

	UnitState = XComGameState_Unit(EventData);
	
	if (UnitState != none && UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier')
	{
		`LOG(default.class @ GetFuncName() @ "AddAdditionalSquaddieAbilities to" @ UnitState.SummaryString(),, 'RPGO-Promotion');

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("ADD_ADDITIONAL_SQUADDIE_ABILITIES");
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));

		class'X2SoldierClassTemplatePlugin'.static.AddAdditionalSquaddieAbilities(NewGameState, UnitState);

		if (NewGameState.GetNumGameStateObjects() > 0)
		{
			`LOG(default.class @ GetFuncName() @ "Submitting Game State",, 'RPGO-Promotion');
			`GAMERULES.SubmitGameState(NewGameState);
		}
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn AssignSoldierSpecializations(Object EventData, Object EventSource, XComGameState GameState, Name EventName, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local array<int> AllSpecs;
	local UnitValue AddedRandomSpecs, AddedCommandersChoiceSpecs, SpecsAssigned;
	local XComGameStateHistory History;
	local bool bCreatedOwnGameState, bHasSpecsAssignend;

	`LOG(default.class @ GetFuncName() @ "Eventlistener triggered:" @ EventName,, 'RPG');

	History = `XCOMHISTORY;

	UnitState = XComGameState_Unit(EventData);
	AllSpecs.Length = 0; // get rid if unused var warning

	//`LOG(default.class @ GetFuncName() @ UnitState.SummaryString() @
	//	"RPGOSpecRoulette" @ `SecondWaveEnabled('RPGOSpecRoulette') @
	//	"RPGOTrainingRoulette" @ `SecondWaveEnabled('RPGOTrainingRoulette') @
	//	"RPGOOrigins" @ `SecondWaveEnabled('RPGOOrigins')
	//,, 'RPG');

	if (UnitState != none)
	{
		UnitState.GetUnitValue('SecondWaveSpecRouletteAddedRandomSpecs', AddedRandomSpecs);
		UnitState.GetUnitValue('SecondWaveCommandersChoiceSpecChosen', AddedCommandersChoiceSpecs);
		UnitState.GetUnitValue('SpecsAssigned', SpecsAssigned);

		bHasSpecsAssignend = AddedRandomSpecs.fValue == 1 || AddedCommandersChoiceSpecs.fValue == 1 || SpecsAssigned.fValue == 1;

		`LOG(default.class @ GetFuncName() @ "---------------------------------------",, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ UnitState.SummaryString(),, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "X2CharacterTemplate:" @ UnitState.GetMyTemplateName(),, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "X2SoldierClassTemplate" @ UnitState.GetSoldierClassTemplateName(),, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "Unit Rank:" @ UnitState.GetSoldierRank(),, 'RPGO-Promotion');

		`LOG(default.class @ GetFuncName() @ "SecondWave Specialization Roulette:" @ `SecondWaveEnabled('RPGOSpecRoulette'),, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "SecondWave Commanders Choice:" @ `SecondWaveEnabled('RPGOCommandersChoice'),, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "SecondWave Origins:" @ `SecondWaveEnabled('RPGOOrigins'),, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "SecondWave Random Classes:" @ `SecondWaveEnabled('RPGO_SWO_RandomClasses'),, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "SecondWave Weapon Restrictions:" @ `SecondWaveEnabled('RPGO_SWO_WeaponRestriction'),, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "SecondWave Training Roulette:" @ `SecondWaveEnabled('RPGOTrainingRoulette'),, 'RPGO-Promotion');

		`LOG(default.class @ GetFuncName() @ "UnitVal AddedRandomSpecs" @ AddedRandomSpecs.fValue,, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "UnitVal SecondWaveCommandersChoiceSpecChosen" @ AddedCommandersChoiceSpecs.fValue,, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "UnitVal SpecsAssigned" @ SpecsAssigned.fValue,, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ `ShowVar(bHasSpecsAssignend),, 'RPGO-Promotion');
		`LOG(default.class @ GetFuncName() @ "---------------------------------------",, 'RPGO-Promotion');

		if (UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier')
		{
			`LOG(default.class @ GetFuncName() @ UnitState.SummaryString() @
				GameState @ GameState.GetNumGameStateObjects() @
				`ShowVar(GameState.HistoryIndex) @
				`ShowVar(History.GetCurrentHistoryIndex())
			,, 'RPGO-Promotion');

			// Some special gamestate handling because some mods tend to submit unit rankup gamestates manually (looking at you commanders choice)
			if (GameState.HistoryIndex < History.GetCurrentHistoryIndex() && GameState.HistoryIndex != INDEX_NONE)
			{
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RPGO_BUILDSPECTREE");
				bCreatedOwnGameState = true;
				`LOG(default.class @ GetFuncName() @ "Created own state" @ NewGameState,, 'RPGO-Promotion');
			}
			else
			{
				`LOG(default.class @ GetFuncName() @ "Using given state" @ GameState,, 'RPGO-Promotion');
				NewGameState = GameState;
			}

			UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));

			if ((`SecondWaveEnabled('RPGOSpecRoulette') || `SecondWaveEnabled('RPGO_SWO_RandomClasses')) && !bHasSpecsAssignend)
			{
				class'X2SecondWaveConfigOptions'.static.BuildRandomSpecAbilityTree(UnitState, `SecondWaveEnabled('RPGOTrainingRoulette'));
				UnitState.SetUnitFloatValue('SecondWaveSpecRouletteAddedRandomSpecs', 1, eCleanup_Never);
				`LOG(default.class @ GetFuncName() @
					UnitState.SummaryString() @
					"Build random spec ability tree"
				,, 'RPGO-Promotion');
			}
			else if (`SecondWaveEnabled('RPGOTrainingRoulette') && !bHasSpecsAssignend)
			{
				class'X2SecondWaveConfigOptions'.static.BuildSpecAbilityTree(UnitState, AllSpecs, true, true);
				UnitState.SetUnitFloatValue('SpecsAssigned', 1, eCleanup_Never);
				`LOG(default.class @ GetFuncName() @
					UnitState.SummaryString() @
					"Build training roulette ability tree"
				,, 'RPGO-Promotion');

			}
			else if (!bHasSpecsAssignend)
			{
				class'X2SecondWaveConfigOptions'.static.BuildSpecAbilityTree(UnitState, AllSpecs, true, false);
				UnitState.SetUnitFloatValue('SpecsAssigned', 1, eCleanup_Never);
				`LOG(default.class @ GetFuncName() @
					UnitState.SummaryString() @
					"Build soldier ability tree"
				,, 'RPGO-Promotion');
			}

			if (class'X2SecondWaveConfigOptions'.static.HasPureRandomSpecializations())
			{
				`XEVENTMGR.TriggerEvent('RPGOSpecializationsAssigned', UnitState, UnitState, NewGameState);
			}

			if (NewGameState.GetNumGameStateObjects() > 0 && bCreatedOwnGameState)
			{
				`LOG(default.class @ GetFuncName() @ "Submitting Game State",, 'RPGO-Promotion');
				`GAMERULES.SubmitGameState(NewGameState);
			}
		}
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnCompleteRespecSoldierSecondWave(Object EventData, Object EventSource, XComGameState GameState, Name EventNAme, Object CallbackData)
{
	local XComGameState_Unit UnitState;
	local UnitValue PreserveSpecs, PreserveAbilities;
	`LOG(default.class @ GetFuncName() @ "Eventlistener triggered:" @ EventName,, 'RPGO-Promotion');

	UnitState = XComGameState_Unit(EventSource);
	
	if (UnitState != none)
	{
		// Refresh UnitState
		UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitState.ObjectID));

		if (UnitState.GetMyTemplateName() == 'Soldier' &&
			UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier')
		{
			UnitState.GetUnitValue('RPGO_RebuildSelectedSoldierPreserveSpecs', PreserveSpecs);
			UnitState.GetUnitValue('RPGO_RebuildSelectedSoldierPreserveAbilities', PreserveAbilities);

			`LOG(default.class @ GetFuncName() @ "RPGOSpecRoulette" @
				UnitState.GetMyTemplateName() @
				UnitState.GetSoldierClassTemplateName() @
				UnitState.GetSoldierRank() @
				"RPGOSpecRoulette" @ `SecondWaveEnabled('RPGOSpecRoulette') @
				"RPGO_SWO_RandomClasses" @ `SecondWaveEnabled('RPGO_SWO_RandomClasses')
			,, 'RPGO-Promotion');

			if (PreserveSpecs.fValue != 1)
			{
				if (`SecondWaveEnabled('RPGOSpecRoulette') || `SecondWaveEnabled('RPGO_SWO_RandomClasses'))
				{
					`LOG(default.class @ GetFuncName() @ "RPGOSpecRoulette Randomizing starting specs",, 'RPGO-Promotion');
					class'X2SecondWaveConfigOptions'.static.BuildRandomSpecAbilityTree(UnitState);
				}
				`LOG(default.class @ GetFuncName() @ "Resetting SecondWaveCommandersChoiceSpecChosen/SecondWaveSpecRouletteAddedRandomSpecs",, 'RPGO-Promotion');
				UnitState.SetUnitFloatValue('SecondWaveCommandersChoiceSpecChosen', 0, eCleanup_Never);
				UnitState.SetUnitFloatValue('SecondWaveSpecRouletteAddedRandomSpecs', 0, eCleanup_Never);
			}
			else
			{
				UnitState.SetUnitFloatValue('RPGO_RebuildSelectedSoldierPreserveSpecs', 0, eCleanup_Never);
			}

			if (PreserveAbilities.fValue != 1)
			{
				UnitState.SetUnitFloatValue('SecondWaveCommandersChoiceAbilityChosen', 0, eCleanup_Never);
			}
			else
			{
				UnitState.SetUnitFloatValue('RPGO_RebuildSelectedSoldierPreserveAbilities', 0, eCleanup_Never);
			}
		}
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnGetLocalizedCategory(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;
	local X2WeaponTemplate Template;
	local string Localization;

	Tuple = XComLWTuple(EventData);
	Template = X2WeaponTemplate(EventSource);

	switch (Template.WeaponCat)
	{
		case 'pistol':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatPistol;
			break;
		case 'sidearm':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatSidearm;
			break;
		case 'sword':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatSword;
			break;
		case 'gremlin':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatGremlin;
			break;
		case 'psiamp':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatPsiamp;
			break;
		case 'grenade_launcher':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatGrenadeLauncher;
			break;
		case 'claymore':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatClaymore;
			break;
		case 'wristblade':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatWristblade;
			break;
		case 'arcthrower':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatArcthrower;
			break;
		case 'combatknife':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatCombatknife;
			break;
		case 'holotargeter':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatHolotargeter;
			break;
		case 'sawedoffshotgun':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatSawedoffshotgun;
			break;
		case 'lw_gauntlet':
			Localization = class'XGLocalizedData_RPG'.default.UtilityCatLWGauntlet;
			break;
		default:
			Localization = Tuple.Data[0].s;
			break;
	}

	Tuple.Data[0].s = Localization;
	EventData = Tuple;
	return ELR_NoInterrupt;
}

static function EventListenerReturn OnSoldierInfo(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;
	local XComGameState_Unit UnitState;
	local string Info, CustomClassIcon, CustomClassTitle, CustomClassDescription;
	local XComGameState_CustomClassInsignia CustomClassInsigniaGameState;

	Tuple = XComLWTuple(EventData);
	UnitState = XComGameState_Unit(EventSource);

	//`LOG(GetFuncName() @ XComGameState_Unit(EventSource).GetFullName(),, 'RPG');

	//if (UnitState.GetSoldierClassTemplate().DataName != 'UniversalSoldier')
	//{
	//	//`LOG(GetFuncName() @ "bailing" @ UnitState.GetSoldierClassTemplate().DisplayName @ UnitState.GetSoldierClassTemplate().DataName,, 'RPG');
	//	return ELR_NoInterrupt;
	//}

	CustomClassInsigniaGameState = class'XComGameState_CustomClassInsignia'.static.GetGameState();
	if (CustomClassInsigniaGameState != none)
	{
		CustomClassIcon = CustomClassInsigniaGameState.GetClassIconForUnit(UnitState.ObjectID);
		CustomClassTitle = CustomClassInsigniaGameState.GetClassTitleForUnit(UnitState.ObjectID);
		CustomClassDescription = CustomClassInsigniaGameState.GetClassDescriptionForUnit(UnitState.ObjectID);
	}
	
	switch (Event)
	{
		case 'SoldierClassIcon':
			if (CustomClassIcon != "")
			{
				Info = "img:///" $ CustomClassIcon;
			}
			else
			{
				Info = GetClassIcon(UnitState);
			}
			break;
		case 'SoldierClassDisplayName':
			if (CustomClassTitle != "")
			{
				Info = CustomClassTitle;
			}
			else
			{
				Info = GetClassDisplayName(UnitState);
			}
			break;
		case 'SoldierClassSummary':
			if (CustomClassDescription != "")
			{
				Info = CustomClassDescription;
			}
			else
			{
				Info = GetClassSummary(UnitState);
			}
			break;
	}

	//`LOG(GetFuncName() @ Event @ Info,, 'RPG');

	Tuple.Data[0].s = Info;
	EventData = Tuple;

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnSecondWaveChanged(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	//local XComGameStateHistory History;
	//local XComGameState_Unit UnitState;
	//local XComGameState_CampaignSettings CurrentCampaignSettings, PreviousCampaignSettings;
	//local UnitValue AddedRandomSpecs;
	//local name SecondWaveOption;
	//local bool bRandomEnabled, bRandomDisabled, bCommandersChoiceEnabled;
	//
	//History = `XCOMHISTORY;
	//
	//CurrentCampaignSettings = XComGameState_CampaignSettings(EventData);
	//CurrentCampaignSettings = XComGameState_CampaignSettings(History.GetGameStateForObjectID(CurrentCampaignSettings.ObjectID, , GameState.HistoryIndex));
	//PreviousCampaignSettings = XComGameState_CampaignSettings(History.GetGameStateForObjectID(CurrentCampaignSettings.ObjectID, , GameState.HistoryIndex - 1));
	//
	//bCommandersChoiceEnabled = (PreviousCampaignSettings.SecondWaveOptions.Find('RPGOCommandersChoice') == INDEX_NONE &&
	//							CurrentCampaignSettings.SecondWaveOptions.Find('RPGOCommandersChoice') != INDEX_NONE);
	//
	//bRandomEnabled = (PreviousCampaignSettings.SecondWaveOptions.Find('RPGOSpecRoulette') == INDEX_NONE &&
	//				  CurrentCampaignSettings.SecondWaveOptions.Find('RPGOSpecRoulette') != INDEX_NONE) ||
	//				 (PreviousCampaignSettings.SecondWaveOptions.Find('RPGO_SWO_RandomClasses') == INDEX_NONE &&
	//				  CurrentCampaignSettings.SecondWaveOptions.Find('RPGO_SWO_RandomClasses') != INDEX_NONE);
	//
	//bRandomDisabled = (PreviousCampaignSettings.SecondWaveOptions.Find('RPGOSpecRoulette') != INDEX_NONE ||
	//				   PreviousCampaignSettings.SecondWaveOptions.Find('RPGO_SWO_RandomClasses') != INDEX_NONE) &&
	//				 (CurrentCampaignSettings.SecondWaveOptions.Find('RPGOSpecRoulette') == INDEX_NONE ||
	//				  CurrentCampaignSettings.SecondWaveOptions.Find('RPGO_SWO_RandomClasses') == INDEX_NONE);
	//
	//foreach History.IterateByClassType(class'XComGameState_Unit', UnitState)
	//{
	//	if (bRandomEnabled)
	//	{
	//		`LOG(GetFuncName() @ "RPGO_SWO_RandomClasses or RPGOSpecRoulette was enabled",, 'RPG');
	//		UnitState.GetUnitValue('SecondWaveSpecRouletteAddedRandomSpecs', AddedRandomSpecs);
	//
	//		if (UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier' &&
	//			AddedRandomSpecs.fValue != 1)
	//		{
	//			AssignSoldierSpecializations(UnitState, none, GameState, '', none);
	//		}
	//	}
	//
	//	if (bRandomDisabled)
	//	{
	//		`LOG(GetFuncName() @ "RPGO_SWO_RandomClasses or RPGOSpecRoulette was disabled",, 'RPG');
	//		UnitState.ClearUnitValue('SecondWaveSpecRouletteAddedRandomSpecs');
	//	}
	//}
	//
	//
	//foreach PreviousCampaignSettings.SecondWaveOptions(SecondWaveOption)
	//{
	//	`LOG(GetFuncName() @ "PreviousCampaignSettings" @ SecondWaveOption,, 'RPG');
	//}
	//
	//foreach CurrentCampaignSettings.SecondWaveOptions(SecondWaveOption)
	//{
	//	`LOG(GetFuncName() @ "CurrentCampaignSettings" @ SecondWaveOption,, 'RPG');
	//}

	return ELR_NoInterrupt;
}

static function string GetClassIcon(XComGameState_Unit UnitState)
{
	local name Spec;
	local X2UniversalSoldierClassInfo Template;

	Spec = GetSpecializationName(UnitState);

	Template = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplateByName(Spec);

	//`LOG(GetFuncName() @ Template @ Template.ClassSpecializationIcon,, 'RPG');

	return Template.ClassSpecializationIcon != "" ? Template.ClassSpecializationIcon : UnitState.GetSoldierClassTemplate().IconImage;
}

static function string GetClassDisplayName(XComGameState_Unit UnitState)
{
	local name Spec;
	local X2UniversalSoldierClassInfo Template;

	Spec = GetSpecializationName(UnitState);

	Template = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplateByName(Spec);

	return Template.ClassSpecializationTitle != "" ? Template.ClassSpecializationTitle : UnitState.GetSoldierClassTemplate().DisplayName;
}

static function name GetSpecializationName(XComGameState_Unit UnitState)
{
	local int RowIndex;
	//local array<SoldierSpecialization> Specs;
	local X2UniversalSoldierClassInfo Spec;
	
	RowIndex = GetSoldierSpecialization(UnitState);

	Spec = class'X2SoldierClassTemplatePlugin'.static.GetSpecTemplateBySlotFromAssignedSpecs(UnitState, RowIndex);
	
	return ((RowIndex != INDEX_NONE) && (Spec != none)) ? Spec.Name : UnitState.GetSoldierClassTemplate().DataName;
}

static function string GetClassSummary(XComGameState_Unit UnitState)
{
	local name Spec;
	local X2UniversalSoldierClassInfo Template;
	local string Summary;

	Spec = GetSpecializationName(UnitState);
	Template = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplateByName(Spec);

	//`LOG(GetFuncName() @ Spec @ Template @ Template.ClassSpecializationSummary,, 'RPG');

	Summary = Template.ClassSpecializationSummary != "" ? Template.ClassSpecializationSummary : UnitState.GetSoldierClassTemplate().ClassSummary;

	if (`SecondWaveEnabled('RPGO_SWO_RandomClasses') || `SecondWaveEnabled('RPGO_SWO_WeaponRestriction'))
	{
		Summary $= "<br />" $ class'X2SoldierClassTemplatePlugin'.static.GetAssignedSpecsMetaInfo(UnitState);
	}


	return Summary;
}

static function int GetSoldierSpecialization(XComGameState_Unit UnitState)
{
	local array<SoldierRankAbilities> AbilityTree;
	local array<SoldierClassAbilityType> Abilities;
	local int RankIndex, RowIndex, DistributionIndex;
	local SoldierClassAbilityType Ability;
	local array<RowDistribution> RowsDistribution;
	local RowDistribution NewRowDistribution;

	AbilityTree = UnitState.AbilityTree;

	// Exclude squaddie rank so we start at index 1
	for (RankIndex = 1; RankIndex < AbilityTree.Length; RankIndex++)
	{
		Abilities = AbilityTree[RankIndex].Abilities;
		for (RowIndex = 0; RowIndex < Abilities.Length; RowIndex++)
		{
			Ability = Abilities[RowIndex];
			
			if (UnitState.HasSoldierAbility(Ability.AbilityName))
			{
				DistributionIndex = RowsDistribution.Find('Row', RowIndex);
				if (DistributionIndex != INDEX_NONE)
				{
					RowsDistribution[DistributionIndex].Count += 7 + RankIndex;
				}
				else
				{
					NewRowDistribution.Row = RowIndex;
					NewRowDistribution.Count = RankIndex;
					RowsDistribution.AddItem(NewRowDistribution);
				}
			}
		}
	}

	RowsDistribution.Sort(SortRowDistribution);
	//`LOG("------------------------------",, 'RPG');
	//foreach RowsDistribution(NewRowDistribution)
	//{
	//	`LOG(NewRowDistribution.Row @ NewRowDistribution.Count,, 'RPG');
	//}

	return (RowsDistribution.Length > 0 && RowsDistribution[0].Count > 0) ? RowsDistribution[0].Row : INDEX_NONE;
}

function int SortRowDistribution(RowDistribution A, RowDistribution B)
{
	return A.Count < B.Count ? -1 : 0;
}

function int SortSpecializations(SoldierSpecialization A, SoldierSpecialization B)
{
	return A.Order > B.Order ? -1 : 0;
}

//	Random Classes BEGIN
static function CHEventListenerTemplate CreateListenerTemplate_WeaponRestrictionsLoadout()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGO_BestGearAppliedListener');

	Template.RegisterInStrategy = true;

	//Template.AddCHEvent('OnBestGearLoadoutApplied', OnBestGearLoadoutApplied_Listener, ELD_OnStateSubmitted);
	Template.AddCHEvent('rjSquadSelect_UpdateData', OnBestGearLoadoutApplied_Listener, ELD_OnStateSubmitted);
	`LOG(default.class @ "Register Event rjSquadSelect_UpdateData",, 'RPG');

	Template.AddCHEvent('RPGOSpecializationsAssigned', RandomClasses_PromotionEventListener, ELD_OnStateSubmitted);	

	return Template;
}

//	This listener runs whenever the player clicks Unequip Barracks in the Squad Select or similar buttons.
static function EventListenerReturn OnBestGearLoadoutApplied_Listener(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState         NewGameState;
	local bool					bChangedSomething;
	local XComGameState_Unit	UnitState;
	local XComGameState_Item	PrimaryWeaponState;
	local XComGameState_Item	SecondaryWeaponState;
	local XComGameState_HeadquartersXCom	XComHQ;
	local array<name>						AllowedWeaponCategories;
	local XComGameStateHistory	History;
	local StateObjectReference	UnitRef;

	//`LOG("OnBestGearLoadoutApplied running.",, 'RPG');

	if (`SecondWaveEnabled('RPGO_SWO_WeaponRestriction'))
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Weapon Restrictions: re-equip new items");
		History = `XCOMHISTORY;
		XComHQ = `XCOMHQ;
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));

		foreach XComHQ.Crew(UnitRef)
		{
			UnitState = XComGameState_Unit(History.GetGameStateForObjectID(UnitRef.ObjectID));
			if (UnitState != none && UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier' && UnitState.IsSoldier() && UnitState.IsAlive())
			{
				//`LOG("OnBestGearLoadoutApplied for " @ UnitState.GetFullName(),, 'RPG');
				PrimaryWeaponState = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);
				SecondaryWeaponState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

				if (PrimaryWeaponState == none || SecondaryWeaponState == none)
				{
					UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
					//`LOG("Current Primary Weapon " @ PrimaryWeaponState.GetMyTemplateName(),, 'RPG');
					//`LOG("Current Secondary Weapon " @ SecondaryWeaponState.GetMyTemplateName(),, 'RPG');

					if (PrimaryWeaponState == none)
					{
						AllowedWeaponCategories = class'X2SoldierClassTemplatePlugin'.static.GetAllowedPrimaryWeaponCategories(UnitState);

						PrimaryWeaponState = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_PrimaryWeapon, AllowedWeaponCategories, XComHQ, NewGameState);

						if (PrimaryWeaponState != none)
						{
							if (UnitState.AddItemToInventory(PrimaryWeaponState, eInvSlot_PrimaryWeapon, NewGameState))
							{
								bChangedSomething = true;
								//`LOG("New Primary Weapon " @ PrimaryWeaponState.GetMyTemplateName(),, 'RPG');
							}
						}
					}

					if (SecondaryWeaponState == none)
					{
						AllowedWeaponCategories = class'X2SoldierClassTemplatePlugin'.static.GetAllowedSecondaryWeaponCategories(UnitState);

						SecondaryWeaponState = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_SecondaryWeapon, AllowedWeaponCategories, XComHQ, NewGameState);

						if (PrimaryWeaponState != none)
						{
							if (UnitState.AddItemToInventory(SecondaryWeaponState, eInvSlot_SecondaryWeapon, NewGameState))
							{
								bChangedSomething = true;
								//`LOG("New Secondary Weapon " @ SecondaryWeaponState.GetMyTemplateName(),, 'RPG');
							}
						}
					}
				}
			}
		}
		
		if (bChangedSomething)
		{
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		}
		else
		{
			`XCOMHISTORY.CleanupPendingGameState(NewGameState);
		}
	}
	return ELR_NoInterrupt;
}

static function EventListenerReturn RandomClasses_PromotionEventListener(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(EventData);
	//`LOG("RPGO Soldier promotion event: " @ UnitState.GetFullName(),, 'RPG');

	if (`SecondWaveEnabled('RPGO_SWO_WeaponRestriction'))
	{
		//	Proceed only if this is a newly promoted RPGO soldier to the rank of squaddie, where they first receive their specializations. 
		//	Proceed only if both Weapon Restrictions and Random Classes SWOs are enabled. 
		if (UnitState != none && UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier')
		{
			//`LOG("Weapon Restrictions: equipping new weapons on soldier:" @ UnitState.GetFullname() @ getfuncname(),, 'RPG');
			WeaponRestrictions_EquipNewWeaponsOnSoldier(UnitState.ObjectID);
		}
	}
	return ELR_NoInterrupt;
}

public static function WeaponRestrictions_EquipNewWeaponsOnSoldier(int UnitObjectID, optional XComGameState UseGameState)
{
	local XComGameState_Unit				UnitState;
	local XComGameState_Item                OldWeaponState;
	local XComGameState_Item                NewWeaponState;
	local XComGameState                     NewGameState;
	local XComGameStateHistory              History;
	local XComGameState_HeadquartersXCom    XComHQ;
	local array<name>						AllowedWeaponCategories;
	
	History = `XCOMHISTORY;

	//	If this function was supplied with a Game State, use that one for all modifications. Otherwise, create an own gamestate.
	if (UseGameState == none)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Weapon Restrictions: equip new items");
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitObjectID));
	}
	else 
	{
		NewGameState = UseGameState;
		
		//	Depending on how this is function is called, the supplied Game State may or may not already contain the Unit State we want to modify, so try to get it first.
		UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(UnitObjectID));
		if (UnitState == none)
		{
			UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitObjectID));
		}
	}
	if (UnitState == none)
	{
		`LOG(GetFuncName() @ "ERROR, no Unit State!" @ UseGameState == none,, 'RPG');
		return;
	}

	//`LOG("Weapon Restrictions: equip new weapons on soldier:"@ UnitState.GetFullName(),, 'RPG');
 
	XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
 
	// try to fix weird behavior caused by CanAddItemToInventory_WeaponRestrictions
	// Commented out for now (06.06.2020)
	//UnitState.bIgnoreItemEquipRestrictions = true;

	OldWeaponState = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);
	if (OldWeaponState != none)
	{
		//`LOG("Old Primary Weapon " @ OldWeaponState.GetMyTemplateName(),, 'RPG');
		AllowedWeaponCategories = class'X2SoldierClassTemplatePlugin'.static.GetAllowedPrimaryWeaponCategories(UnitState);
		
		//	Soldier has a weapon equipped, but they're not supposed to be able to use it.
		if (AllowedWeaponCategories.Find(OldWeaponState.GetWeaponCategory()) == INDEX_NONE)
		{
			//	Attempt to replace.
			OldWeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', OldWeaponState.ObjectID));
			DetachAndDestroyWeaponVisualizer(OldWeaponState);

			if (UnitState.RemoveItemFromInventory(OldWeaponState, NewGameState))
			{
				NewWeaponState = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_PrimaryWeapon, AllowedWeaponCategories, XComHQ, NewGameState);
 
				if (NewWeaponState != none)
				{
					NewWeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', NewWeaponState.ObjectID));
					if (UnitState.AddItemToInventory(NewWeaponState, eInvSlot_PrimaryWeapon, NewGameState))
					{
						//`LOG("New Primary Weapon " @ NewWeaponState.GetMyTemplateName(),, 'RPG');
						XComHQ.PutItemInInventory(NewGameState, OldWeaponState);
					}
					else
					{  
						//  If for some magical reason could not equip a new weapon on the unit, equip the old weapon back.
						`LOG("ERROR, could not equip New Primary Weapon on the soldier:" @ NewWeaponState.GetMyTemplateName(),, 'RPG');
						UnitState.AddItemToInventory(OldWeaponState, eInvSlot_PrimaryWeapon, NewGameState);
					}
				}
			}
		}
	}
	else	//	Unit doesn't have a primary weapon equipped. Shouldn't be possible, but let's cover it anyway.
	{
		AllowedWeaponCategories = class'X2SoldierClassTemplatePlugin'.static.GetAllowedPrimaryWeaponCategories(UnitState);
		NewWeaponState = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_PrimaryWeapon, AllowedWeaponCategories, XComHQ, NewGameState);
 
		if (NewWeaponState != none)
		{
			NewWeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', NewWeaponState.ObjectID));
			if (UnitState.AddItemToInventory(NewWeaponState, eInvSlot_PrimaryWeapon, NewGameState))
			{
				//`LOG("New Primary Weapon " @ NewWeaponState.GetMyTemplateName(),, 'RPG');
			}
			else 
			{
				`LOG("ERROR, could not equip New Primary Weapon on the soldier:" @ NewWeaponState.GetMyTemplateName(),, 'RPG');
				NewGameState.RemoveStateObject(NewWeaponState.ObjectID);
			}
		}
	}
 
	OldWeaponState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);
	if (OldWeaponState != none)
	{
		//`LOG("Old Secondary Weapon " @ OldWeaponState.GetMyTemplateName(),, 'RPG');
		AllowedWeaponCategories = class'X2SoldierClassTemplatePlugin'.static.GetAllowedSecondaryWeaponCategories(UnitState);
		
		//	Soldier has a weapon equipped, but they're not supposed to be able to use it.
		if (AllowedWeaponCategories.Find(OldWeaponState.GetWeaponCategory()) == INDEX_NONE)
		{
			//	Attempt to replace.
			OldWeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', OldWeaponState.ObjectID));
			DetachAndDestroyWeaponVisualizer(OldWeaponState);

			if (UnitState.RemoveItemFromInventory(OldWeaponState, NewGameState))
			{
				NewWeaponState = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_SecondaryWeapon, AllowedWeaponCategories, XComHQ, NewGameState);
				NewWeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', NewWeaponState.ObjectID));

				if (NewWeaponState != none)
				{
					if (UnitState.AddItemToInventory(NewWeaponState, eInvSlot_SecondaryWeapon, NewGameState))
					{
						//`LOG("New Secondary Weapon " @ NewWeaponState.GetMyTemplateName(),, 'RPG');
						XComHQ.PutItemInInventory(NewGameState, OldWeaponState);
					}
					else
					{  
						//  If for some magical reason could not equip a new weapon on the unit, equip the old weapon back.
						`LOG("ERROR, could not equip New Secondary Weapon on the soldier:" @ NewWeaponState.GetMyTemplateName(),, 'RPG');
						UnitState.AddItemToInventory(OldWeaponState, eInvSlot_SecondaryWeapon, NewGameState);
					}
				}
			}
		}
	}
	else
	{
		AllowedWeaponCategories = class'X2SoldierClassTemplatePlugin'.static.GetAllowedSecondaryWeaponCategories(UnitState);
		NewWeaponState = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_SecondaryWeapon, AllowedWeaponCategories, XComHQ, NewGameState);
		NewWeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', NewWeaponState.ObjectID));

		if (NewWeaponState != none)
		{
			if (UnitState.AddItemToInventory(NewWeaponState, eInvSlot_SecondaryWeapon, NewGameState))
			{
				//`LOG("New Secondary Weapon " @ NewWeaponState.GetMyTemplateName(),, 'RPG');
			}
			else 
			{
				`LOG("ERROR, could not equip New Secondary Weapon on the soldier:" @ NewWeaponState.GetMyTemplateName(),, 'RPG');
				NewGameState.RemoveStateObject(NewWeaponState.ObjectID);
			}
		}
	}

	// Commented out for now (06.06.2020)
	//UnitState.bIgnoreItemEquipRestrictions = false;

	if (UseGameState == none)
	{
		if (NewGameState.GetNumGameStateObjects() > 0)
		{
			UnitState.ValidateLoadout(NewGameState);
			`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
		}
		else
		{
			`XCOMHISTORY.CleanupPendingGameState(NewGameState);
		}
	}
}


//	Find highest tier infinite weapon that specified soldier can equip into specified slot.
private static function XComGameState_Item FindBestInfiniteWeaponForUnit(const XComGameState_Unit UnitState, const EInventorySlot eSlot, array<name> AllowedWeaponCategories, out XComGameState_HeadquartersXCom XComHQ, out XComGameState NewGameState)
{
	local X2WeaponTemplate		WeaponTemplate;
	local XComGameStateHistory	History;
	local int					HighestTier;
	local XComGameState_Item	ItemState;
	local XComGameState_Item	BestItemState;
	local StateObjectReference	ItemRef;

	HighestTier = -999;
	History = `XCOMHISTORY;

	foreach XComHQ.Inventory(ItemRef)
	{
		ItemState = XComGameState_Item(History.GetGameStateForObjectID(ItemRef.ObjectID));
		WeaponTemplate = X2WeaponTemplate(ItemState.GetMyTemplate());

		if (WeaponTemplate != none)
		{
			if (WeaponTemplate.InventorySlot == eSlot && WeaponTemplate.bInfiniteItem && AllowedWeaponCategories.Find(WeaponTemplate.WeaponCat) != INDEX_NONE)
			{
				if (WeaponTemplate.Tier > HighestTier)
				{
					HighestTier = WeaponTemplate.Tier;
					BestItemState = ItemState;
				}
			}
		}
	}
	
	if (HighestTier != -999)
	{
		
		return BestItemState.GetMyTemplate().CreateInstanceFromTemplate(NewGameState);
	}
	else
	{
		return none;
	}
}

// Aggressively get rid of the old weapon visualizer
static function DetachAndDestroyWeaponVisualizer(XComGameState_Item WeaponState)
{
	local XGWeapon							Weapon;
	local UIArmory							ArmoryScreen;

	Weapon = XGWeapon(WeaponState.GetVisualizer());
	// Weapon must be graphically detach, otherwise destroying it leaves a NULL component attached at that socket
	ArmoryScreen = UIArmory(`ScreenStack.GetLastInstanceOf(class'UIArmory'));
	if (ArmoryScreen != none && ArmoryScreen.ActorPawn != none && Weapon != none)
	{
		XComUnitPawn(ArmoryScreen.ActorPawn).DetachItem(Weapon.GetEntity().Mesh);
		Weapon.Destroy();
	}
}

//	Random Classes END