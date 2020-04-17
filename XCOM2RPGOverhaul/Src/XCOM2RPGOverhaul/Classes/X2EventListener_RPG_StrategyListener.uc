class X2EventListener_RPG_StrategyListener extends X2EventListener dependson(X2SoldierClassTemplatePlugin) config (RPG);

struct RowDistribution
{
	var int Row;
	var int Count;
};


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate_OnUnitRankUp());
	Templates.AddItem(CreateListenerTemplate_OnCompleteRespecSoldier());
	Templates.AddItem(CreateListenerTemplate_OnSoldierInfo());
	Templates.AddItem(CreateListenerTemplate_OnGetLocalizedCategory());
	Templates.AddItem(CreateListenerTemplate_OnSecondWaveChanged());

	//	Random Classes
	Templates.AddItem(CreateListenerTemplate_OnBestGearLoadoutApplied());

	return Templates;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnUnitRankUp()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGUnitRankUpSecondWaveRoulette');

	Template.RegisterInStrategy = true;

	Template.AddCHEvent('UnitRankUp', OnUnitRankUpSecondWaveRoulette, ELD_OnStateSubmitted);
	// compatibility with Commanders Choice Wotc
	Template.AddCHEvent('UnitRankUp', OnUnitRankUpSecondWaveRoulette, ELD_Immediate);
	`LOG(default.class @ "Register Event OnUnitRankUpSecondWaveRoulette",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnCompleteRespecSoldier()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGCompleteRespecSoldierSWTR');

	Template.RegisterInStrategy = true;

	Template.AddCHEvent('CompleteRespecSoldier', OnCompleteRespecSoldierSWTR, ELD_OnStateSubmitted);
	`LOG(default.class @ "Register Event OnCompleteRespecSoldierSWTR",, 'RPG');

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


static function EventListenerReturn OnUnitRankUpSecondWaveRoulette(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local array<int> AllSpecs;
	local UnitValue AddedRandomSpecs;
	local XComGameStateHistory History;
	local bool bCreatedOwnGameState;

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

		`LOG(default.class @ GetFuncName() @
			UnitState.SummaryString() @
			UnitState.GetMyTemplateName() @
			UnitState.GetSoldierClassTemplateName() @
			UnitState.GetSoldierRank() @ 
			"AddedRandomSpecs" @ AddedRandomSpecs.fValue
			,, 'RPG');

		if (UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier' &&
			AddedRandomSpecs.fValue != 1 &&
			(`SecondWaveEnabled('RPGOSpecRoulette') || `SecondWaveEnabled('RPGOTrainingRoulette') || `SecondWaveEnabled('RPGO_SWO_RandomClasses'))
		)
		{
			`LOG(default.class @ GetFuncName() @ UnitState.SummaryString() @
				"RPGOSpecRoulette Randomizing starting specs" @
				GameState @ GameState.GetNumGameStateObjects() @
				`ShowVar(GameState.HistoryIndex) @
				`ShowVar(History.GetCurrentHistoryIndex())
			,, 'RPG');

			// Some special gamestate handling because some mods tend to submit unit rankup gamestates manually (looking at you commanders choice)
			if (GameState.HistoryIndex < History.GetCurrentHistoryIndex() && GameState.HistoryIndex != INDEX_NONE)
			{
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RPGO_SWO_ROULETTE");
				bCreatedOwnGameState = true;
			}
			else
			{
				NewGameState = GameState;
			}

			UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));

			if (`SecondWaveEnabled('RPGOSpecRoulette') || `SecondWaveEnabled('RPGO_SWO_RandomClasses'))
			{
				class'X2SecondWaveConfigOptions'.static.BuildRandomSpecAbilityTree(UnitState, `SecondWaveEnabled('RPGOTrainingRoulette'));
			}
			else if (`SecondWaveEnabled('RPGOTrainingRoulette'))
			{
				class'X2SecondWaveConfigOptions'.static.BuildSpecAbilityTree(UnitState, AllSpecs, true, true);
			}

			UnitState.SetUnitFloatValue('SecondWaveSpecRouletteAddedRandomSpecs', 1, eCleanup_Never);

			//`XCOMHISTORY.AddGameStateToHistory(NewGameState);
			if (NewGameState.GetNumGameStateObjects() > 0 && bCreatedOwnGameState)
			{
				`XCOMHISTORY.AddGameStateToHistory(NewGameState);
			}
		}
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnCompleteRespecSoldierSWTR(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(EventSource);

	if (UnitState != none)
	{
		`LOG(default.class @ GetFuncName() @ "RPGOSpecRoulette" @
			UnitState.GetMyTemplateName() @
			UnitState.GetSoldierClassTemplateName() @
			UnitState.GetSoldierRank() @
			"RPGOSpecRoulette" @ `SecondWaveEnabled('RPGOSpecRoulette') @
			"RPGO_SWO_RandomClasses" @ `SecondWaveEnabled('RPGO_SWO_RandomClasses')
		,, 'RPG');

		if (UnitState.GetMyTemplateName() == 'Soldier' &&
			UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier')
		{
			if (`SecondWaveEnabled('RPGOSpecRoulette') || `SecondWaveEnabled('RPGO_SWO_RandomClasses'))
			{
				`LOG(default.class @ GetFuncName() @ "RPGOSpecRoulette Randomizing starting specs",, 'RPG');
				class'X2SecondWaveConfigOptions'.static.BuildRandomSpecAbilityTree(UnitState);
			}

			UnitState.SetUnitFloatValue('SecondWaveCommandersChoiceSpecChosen', 0, eCleanup_Never);
			UnitState.SetUnitFloatValue('SecondWaveCommandersChoiceAbilityChosen', 0, eCleanup_Never);
			UnitState.SetUnitFloatValue('SecondWaveSpecRouletteAddedRandomSpecs', 0, eCleanup_Never);

			//GameState.AddStateObject(UnitState);
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

	if (UnitState.GetSoldierClassTemplate().DataName != 'UniversalSoldier')
	{
		//`LOG(GetFuncName() @ "bailing" @ UnitState.GetSoldierClassTemplate().DisplayName @ UnitState.GetSoldierClassTemplate().DataName,, 'RPG');
		return ELR_NoInterrupt;
	}

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
	//			OnUnitRankUpSecondWaveRoulette(UnitState, none, GameState, '', none);
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

	//class'X2TemplateHelper_RPGOverhaul'.default.Specializations.Sort(SortSpecializations);
	//Specs = class'X2TemplateHelper_RPGOverhaul'.default.Specializations;

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
static function CHEventListenerTemplate CreateListenerTemplate_OnBestGearLoadoutApplied()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGO_BestGearAppliedListener');

	Template.RegisterInStrategy = true;

	Template.AddCHEvent('OnBestGearLoadoutApplied', OnBestGearLoadoutApplied_Listener, ELD_Immediate);

	//	Setting low priority so the unit gets specializations assigned by an event listener above
	Template.AddCHEvent('UnitRankUp', OnUnitRankUp_RandomClass, ELD_OnStateSubmitted, 10);

	`LOG(default.class @ "Register Event OnBestGearLoadoutApplied",, 'RPG');

	return Template;
}



static function EventListenerReturn OnBestGearLoadoutApplied_Listener(Object EventData, Object EventSource, XComGameState NewGameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit	UnitState;
	local XComGameState_Item	PrimaryWeaponState;
	local XComGameState_Item	SecondaryWeaponState;
	local XComGameState_HeadquartersXCom	XComHQ;

	//	This gets us Unit State from History
	UnitState = XComGameState_Unit(EventData);
	//	Here we get the Unit State from pending New Game State.
	UnitState = XComGameState_Unit(NewGameState.GetGameStateForObjectID(UnitState.ObjectID));

	XComHQ = `XCOMHQ;
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.GetGameStateForObjectID(XComHQ.ObjectID));
	if (XComHQ == none)
	{
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	}

	//`LOG("OnBestGearLoadoutApplied for " @ UnitState.GetFullName(),, 'RPG');

	if (UnitState != none)
	{
		PrimaryWeaponState = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);
		SecondaryWeaponState = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);

		//`LOG("Primary Weapon " @ PrimaryWeaponState.GetMyTemplateName(),, 'RPG');
		//`LOG("Secondary Weapon " @ SecondaryWeaponState.GetMyTemplateName(),, 'RPG');

		if (PrimaryWeaponState == none || SecondaryWeaponState == none)
		{
			if (PrimaryWeaponState == none)
			{
				PrimaryWeaponState = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_PrimaryWeapon, XComHQ, NewGameState);

				if (PrimaryWeaponState != none)
				{
					UnitState.AddItemToInventory(PrimaryWeaponState, eInvSlot_PrimaryWeapon, NewGameState);
				}
			}

			if (SecondaryWeaponState == none)
			{
				SecondaryWeaponState = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_SecondaryWeapon, XComHQ, NewGameState);

				if (PrimaryWeaponState != none)
				{
					UnitState.AddItemToInventory(SecondaryWeaponState, eInvSlot_SecondaryWeapon, NewGameState);
				}
			}
		}
	}
	return ELR_NoInterrupt;
}

//	Find highest tier infinite weapon that specified soldier can equip into specified slot.
private static function XComGameState_Item FindBestInfiniteWeaponForUnit(const XComGameState_Unit UnitState, const EInventorySlot eSlot, out XComGameState_HeadquartersXCom XComHQ, out XComGameState NewGameState)
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
			if (WeaponTemplate.InventorySlot == eSlot && WeaponTemplate.bInfiniteItem &&
				UnitState.CanAddItemToInventory(WeaponTemplate, eSlot, NewGameState, ItemState.Quantity, ItemState))
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
		XComHQ.GetItemFromInventory(NewGameState, BestItemState.GetReference(), BestItemState);
		return BestItemState;
	}
	else
	{
		return none;
	}
}

static function EventListenerReturn OnUnitRankUp_RandomClass(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit                UnitState;
	local XComGameState_Item                OldWeapon;
	local XComGameState_Item                NewWeapon;
	local XComGameState                     NewGameState;
	local XComGameStateHistory              History;
	local XComGameState_HeadquartersXCom    XComHQ;
	local UnitValue                     UV;
 
	UnitState = XComGameState_Unit(EventData);
	UnitState.GetUnitValue('PrimarySpecialization_Value', UV);
 
	`LOG("Unit rank up: " @ UnitState.GetFullName() @ UnitState.GetRank() @ UV.fValue,, 'RPG');
 
	if (UnitState != none && UnitState.GetRank() == 1 && `SecondWaveEnabled('RPGO_SWO_WeaponRestriction') && UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier')
	{
		History = `XCOMHISTORY;
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Equipping squaddie items on unit: " @ UnitState.GetFullName());
 
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
 
		UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));
 
		OldWeapon = UnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);
		`LOG("Old Primary Weapon " @ OldWeapon.GetMyTemplateName(),, 'RPG');
		if (OldWeapon != none)
		{
			if (UnitState.RemoveItemFromInventory(OldWeapon, NewGameState))
			{
				NewWeapon = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_PrimaryWeapon, XComHQ, NewGameState);
 
				if (NewWeapon != none)
				{
					if (UnitState.AddItemToInventory(NewWeapon, eInvSlot_PrimaryWeapon, NewGameState))
					{
						`LOG("New Primary Weapon " @ NewWeapon.GetMyTemplateName(),, 'RPG');
						XComHQ.PutItemInInventory(NewGameState, OldWeapon);
					}
					else
					{  
						//  If for some magical reason could not equip a new weapon on the unit, equip the old weapon back.
						`LOG("ERROR, could not equip New Primary Weapon on the soldier:" @ NewWeapon.GetMyTemplateName(),, 'RPG');
						UnitState.AddItemToInventory(OldWeapon, eInvSlot_PrimaryWeapon, NewGameState);
					}
				}
			}
		}
		else
		{
			NewWeapon = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_PrimaryWeapon, XComHQ, NewGameState);
 
				if (NewWeapon != none)
				{
					if (UnitState.AddItemToInventory(NewWeapon, eInvSlot_PrimaryWeapon, NewGameState))
					{
						`LOG("New Primary Weapon " @ NewWeapon.GetMyTemplateName(),, 'RPG');
					}
					else `LOG("ERROR, could not equip New Primary Weapon on the soldier:" @ NewWeapon.GetMyTemplateName(),, 'RPG');
				}
		}
 
		OldWeapon = UnitState.GetItemInSlot(eInvSlot_SecondaryWeapon);
	   
		if (OldWeapon != none)
		{
			`LOG("Old Secondary Weapon " @ OldWeapon.GetMyTemplateName(),, 'RPG');
			if (UnitState.RemoveItemFromInventory(OldWeapon, NewGameState))
			{
				NewWeapon = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_SecondaryWeapon, XComHQ, NewGameState);
 
				if (NewWeapon != none)
				{
					if (UnitState.AddItemToInventory(NewWeapon, eInvSlot_SecondaryWeapon, NewGameState))
					{
						`LOG("New Secondary Weapon " @ NewWeapon.GetMyTemplateName(),, 'RPG');
						XComHQ.PutItemInInventory(NewGameState, OldWeapon);
					}
					else
					{  
						//  If for some magical reason could not equip a new weapon on the unit, equip the old weapon back.
						`LOG("ERROR, could not equip New Secondary Weapon on the soldier:" @ NewWeapon.GetMyTemplateName(),, 'RPG');
						UnitState.AddItemToInventory(OldWeapon, eInvSlot_PrimaryWeapon, NewGameState);
					}
				}
			}
		}
		else
		{
			NewWeapon = FindBestInfiniteWeaponForUnit(UnitState, eInvSlot_SecondaryWeapon, XComHQ, NewGameState);
			if (NewWeapon != none)
			{
				if (UnitState.AddItemToInventory(NewWeapon, eInvSlot_SecondaryWeapon, NewGameState))
				{
					`LOG("New Secondary Weapon " @ NewWeapon.GetMyTemplateName(),, 'RPG');
				}
				else `LOG("ERROR, could not equip New Secondary Weapon on the soldier:" @ NewWeapon.GetMyTemplateName(),, 'RPG');
			}
		}
 
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);
	}
	return ELR_NoInterrupt;
}
//	Random Classes END
