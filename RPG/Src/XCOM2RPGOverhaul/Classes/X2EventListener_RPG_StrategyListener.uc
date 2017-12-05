class X2EventListener_RPG_StrategyListener extends X2EventListener config (RPG);

struct RowDistribution
{
	var int Row;
	var int Count;
};

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate_OnSoldierInfo());
	Templates.AddItem(CreateListenerTemplate_OnGetLocalizedCategory());

	return Templates;
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

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGSoldierInfo');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('GetLocalizedCategory', OnGetLocalizedCategory, ELD_Immediate);
	`LOG("Register Event OnGetLocalizedCategory",, 'RPG');

	return Template;
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

	`LOG(GetFuncName() @ XComGameState_Unit(EventSource).GetFullName(),, 'RPG');

	if (UnitState.GetSoldierClassTemplate().DataName != 'UniversalSoldier')
	{
		`LOG(GetFuncName() @ "bailing" @ UnitState.GetSoldierClassTemplate().DisplayName @ UnitState.GetSoldierClassTemplate().DataName,, 'RPG');
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

	`LOG(GetFuncName() @ Event @ Info,, 'RPG');

	Tuple.Data[0].s = Info;
	EventData = Tuple;

	return ELR_NoInterrupt;
}

static function string GetClassIcon(XComGameState_Unit UnitState)
{
	local int RowIndex;

	RowIndex = GetSoldierSpecialization(UnitState);
	return RowIndex != INDEX_NONE ? class'X2UniversalSoldierClassInfo'.default.ClassSpecializationIcons[RowIndex] : UnitState.GetSoldierClassTemplate().IconImage;
}

static function string GetClassDisplayName(XComGameState_Unit UnitState)
{
	local int RowIndex;

	RowIndex = GetSoldierSpecialization(UnitState);
	return RowIndex != INDEX_NONE ? UnitState.GetSoldierClassTemplate().AbilityTreeTitles[RowIndex] : UnitState.GetSoldierClassTemplate().DisplayName;
}

static function string GetClassSummary(XComGameState_Unit UnitState)
{
	local int RowIndex;

	RowIndex = GetSoldierSpecialization(UnitState);
	return RowIndex != INDEX_NONE ? class'X2UniversalSoldierClassInfo'.default.ClassSpecializationSummaries[RowIndex] : UnitState.GetSoldierClassTemplate().ClassSummary;
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
					RowsDistribution[DistributionIndex].Count += 1;
				}
				else
				{
					NewRowDistribution.Row = RowIndex;
					NewRowDistribution.Count = 1;
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