class X2EventListener_RPG_StrategyListener extends X2EventListener config (RPG);

struct RowDistribution
{
	var int Row;
	var int Count;
};

struct SoldierSpecialization
{
	var int Order;
	var name TemplateName;
	var bool bEnabled;
	structdefaultproperties
	{
		bEnabled = true
	}
};


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate_OnUnitRankUp());
	Templates.AddItem(CreateListenerTemplate_OnCompleteRespecSoldier());
	Templates.AddItem(CreateListenerTemplate_OnSoldierInfo());
	Templates.AddItem(CreateListenerTemplate_OnGetLocalizedCategory());

	return Templates;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnUnitRankUp()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGUnitRankUpSecondWaveRoulette');

	Template.RegisterInStrategy = true;

	Template.AddCHEvent('UnitRankUp', OnUnitRankUpSecondWaveRoulette, ELD_OnStateSubmitted);
	`LOG("Register Event OnUnitRankUpSecondWaveRoulette",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnCompleteRespecSoldier()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGCompleteRespecSoldierSWTR');

	Template.RegisterInStrategy = true;

	Template.AddCHEvent('CompleteRespecSoldier', OnCompleteRespecSoldierSWTR, ELD_OnStateSubmitted);
	`LOG("Register Event OnCompleteRespecSoldierSWTR",, 'RPG');

	return Template;
}


static function CHEventListenerTemplate CreateListenerTemplate_OnSoldierInfo()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGSoldierInfo');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('SoldierClassIcon', OnSoldierInfo, ELD_Immediate);
	`LOG("Register Event SoldierClassIcon",, 'RPG');

	Template.AddCHEvent('SoldierClassDisplayName', OnSoldierInfo, ELD_Immediate);
	`LOG("Register Event SoldierClassDisplayName",, 'RPG');

	Template.AddCHEvent('SoldierClassSummary', OnSoldierInfo, ELD_Immediate);
	`LOG("Register Event SoldierClassSummary",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnGetLocalizedCategory()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGetLocalizedCategory');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('GetLocalizedCategory', OnGetLocalizedCategory, ELD_Immediate);
	`LOG("Register Event OnGetLocalizedCategory",, 'RPG');

	return Template;
}

static function EventListenerReturn OnUnitRankUpSecondWaveRoulette(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local array<int> AllSpecs;

	UnitState = XComGameState_Unit(EventData);

	`LOG(default.class @ GetFuncName() @ UnitState @ "RPGOSpecRoulette" @ `SecondWaveEnabled('RPGOSpecRoulette') @ "RPGOTrainingRoulette" @ `SecondWaveEnabled('RPGOTrainingRoulette'),, 'RPG');

	if (UnitState != none)
	{
		`LOG(default.class @ GetFuncName() @ "RPGOSpecRoulette" @
			UnitState.GetMyTemplateName() @
			UnitState.GetSoldierClassTemplateName() @
			UnitState.GetSoldierRank()
			,, 'RPG');

		if (UnitState.GetMyTemplateName() == 'Soldier' &&
			UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier' &&
			UnitState.GetSoldierRank() == 1 &&
			(`SecondWaveEnabled('RPGOSpecRoulette') || `SecondWaveEnabled('RPGOTrainingRoulette'))
		)
		{
			`LOG(default.class @ GetFuncName() @ "RPGOSpecRoulette Randomizing starting specs",, 'RPG');

			NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("RPGO_SWO_ROULETTE");

			if (`SecondWaveEnabled('RPGOSpecRoulette'))
			{
				class'X2SecondWaveConfigOptions'.static.BuildRandomSpecAbilityTree(UnitState, `SecondWaveEnabled('RPGOTrainingRoulette'));
			}
			else if (`SecondWaveEnabled('RPGOTrainingRoulette'))
			{
				class'X2SecondWaveConfigOptions'.static.BuildSpecAbilityTree(UnitState, AllSpecs, true, true);
			}
	
			UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));
			UnitState.SetUnitFloatValue('SecondWaveSpecRouletteAddedRandomSpecs', 1, eCleanup_Never);
			
			`XCOMHISTORY.AddGameStateToHistory(NewGameState);
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
			`SecondWaveEnabled('RPGOSpecRoulette'),, 'RPG');

		if (UnitState.GetMyTemplateName() == 'Soldier' &&
			UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier' &&
			`SecondWaveEnabled('RPGOSpecRoulette'))
		{
			`LOG(default.class @ GetFuncName() @ "RPGOSpecRoulette Randomizing starting specs",, 'RPG');
			class'X2SecondWaveConfigOptions'.static.BuildRandomSpecAbilityTree(UnitState);
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
	local string Info;

	Tuple = XComLWTuple(EventData);
	UnitState = XComGameState_Unit(EventSource);

	//`LOG(GetFuncName() @ XComGameState_Unit(EventSource).GetFullName(),, 'RPG');

	if (UnitState.GetSoldierClassTemplate().DataName != 'UniversalSoldier')
	{
		//`LOG(GetFuncName() @ "bailing" @ UnitState.GetSoldierClassTemplate().DisplayName @ UnitState.GetSoldierClassTemplate().DataName,, 'RPG');
		return ELR_NoInterrupt;
	}

	switch (Event)
	{
		case 'SoldierClassIcon':
			Info = GetClassIcon(UnitState);
			break;
		case 'SoldierClassDisplayName':
			Info = GetClassDisplayName(UnitState);
			break;
		case 'SoldierClassSummary':
			Info = GetClassSummary(UnitState);
			break;
	}

	//`LOG(GetFuncName() @ Event @ Info,, 'RPG');

	Tuple.Data[0].s = Info;
	EventData = Tuple;

	return ELR_NoInterrupt;
}

static function string GetClassIcon(XComGameState_Unit UnitState)
{
	local name Spec;
	local X2UniversalSoldierClassInfo Template;

	Spec = GetSpecializationName(UnitState);

	Template = new(None, string(Spec))class'X2UniversalSoldierClassInfo';

	//`LOG(GetFuncName() @ Template @ Template.ClassSpecializationIcon,, 'RPG');

	return Template.ClassSpecializationIcon != "" ? Template.ClassSpecializationIcon : UnitState.GetSoldierClassTemplate().IconImage;
}

static function string GetClassDisplayName(XComGameState_Unit UnitState)
{
	local name Spec;
	local X2UniversalSoldierClassInfo Template;

	Spec = GetSpecializationName(UnitState);

	Template = new(None, string(Spec))class'X2UniversalSoldierClassInfo';

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

	Spec = class'X2SoldierClassTemplatePlugin'.static.GetSpecializationTemplateForSlot(UnitState, RowIndex);
	
	return ((RowIndex != INDEX_NONE) && (Spec != none)) ? Spec.Name : UnitState.GetSoldierClassTemplate().DataName;
}

static function string GetClassSummary(XComGameState_Unit UnitState)
{
	local name Spec;
	local X2UniversalSoldierClassInfo Template;

	Spec = GetSpecializationName(UnitState);

	Template = new(None, string(Spec))class'X2UniversalSoldierClassInfo';

	//`LOG(GetFuncName() @ Spec @ Template @ Template.ClassSpecializationSummary,, 'RPG');
	return Template.ClassSpecializationSummary != "" ? Template.ClassSpecializationSummary : UnitState.GetSoldierClassTemplate().ClassSummary;
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

	return RowsDistribution[0].Count > 0 ? RowsDistribution[0].Row : INDEX_NONE;
}

function int SortRowDistribution(RowDistribution A, RowDistribution B)
{
	return A.Count < B.Count ? -1 : 0;
}

function int SortSpecializations(SoldierSpecialization A, SoldierSpecialization B)
{
	return A.Order > B.Order ? -1 : 0;
}
