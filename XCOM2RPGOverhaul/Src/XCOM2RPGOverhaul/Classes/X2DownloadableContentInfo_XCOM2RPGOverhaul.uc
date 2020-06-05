class X2DownloadableContentInfo_XCOM2RPGOverhaul extends X2DownloadableContentInfo config(RPG);

var config array<ModClassOverrideEntry> ModClassOverrides;
var config array<string> IncompatibleMods;
var config array<string> RequiredMods;
var config string DisplayName;

static function OnPreCreateTemplates()
{
	PatchModClassOverrides();
}

static function PatchModClassOverrides()
{
	local Engine LocalEngine;
	local ModClassOverrideEntry MCO;
	local int Index;

	LocalEngine = class'Engine'.static.GetEngine();
	foreach default.ModClassOverrides(MCO)
	{
		LocalEngine.ModClassOverrides.AddItem(MCO);
		`LOG(GetFuncName() @ "Adding" @ MCO.BaseGameClass @ MCO.ModClass,, 'RPG');
	}

	for (Index =  LocalEngine.ModClassOverrides.Length - 1; Index >= 0; Index--)
	{
		MCO =  LocalEngine.ModClassOverrides[Index];

		if (default.ModClassOverrides.Find('BaseGameClass', MCO.BaseGameClass) != INDEX_NONE &&
			default.ModClassOverrides.Find('ModClass', MCO.ModClass) == INDEX_NONE)
		{
			`LOG(GetFuncName() @ "Found incompatible MCO. Removing" @ MCO.BaseGameClass @ MCO.ModClass @ Index,, 'RPG');
				LocalEngine.ModClassOverrides.Remove(Index, 1);
		}
	}
}


static event OnPostTemplatesCreated()
{
	class'X2SoldierClassTemplatePlugin'.static.SetupSpecialization('UniversalSoldier');
	class'X2TemplateHelper_RPGOverhaul'.static.AddSecondWaveOptions();
	class'X2TemplateHelper_RPGOverhaul'.static.RemoveJediClassSoldierInfoEventistenerTemplate();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchAcademyUnlocks('UniversalSoldier');
	class'X2TemplateHelper_RPGOverhaul'.static.PatchAbilityPrerequisites();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchAbilitiesWeaponCondition();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchWeapons();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchSkirmisherReturnFire();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchHolotargeting();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchSquadSight();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchSniperStandardFire();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchStandardShot();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchRemoteStart();
//	class'X2TemplateHelper_RPGOverhaul'.static.PatchLongWatch();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchSuppression();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchKillZone();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchSkirmisherGrapple();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchThrowClaymore();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchSwordSlice();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchBladestormAttack();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchMedicalProtocol();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchTraceRounds();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchSteadyHands();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchClaymoreCharges();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchSpecialShotAbiitiesForLightEmUp();

	if (class'X2TemplateHelper_ExtendedUpgrades'.default.bReconfigureVanillaAttachements)
	{
		class'X2TemplateHelper_ExtendedUpgrades'.static.PatchTemplates();
		class'X2TemplateHelper_ExtendedUpgrades'.static.ReconfigDefaultAttachments();
	}

	if (class'X2TemplateHelper_ExtendedUpgrades'.static.IsModInstalled('X2DownloadableContentInfo_X2WOTCCommunityHighlander'))
	{
		class'X2TemplateHelper_ExtendedUpgrades'.static.AddLootTables();
	}
}

// Double tactical ability points
static event InstallNewCampaign(XComGameState StartState)
{
	class'XComGameState_CustomClassInsignia'.static.CreateGameState(StartState);

	//local XComGameState_HeadquartersXCom XComHQ;

	//XComHQ = class'X2TemplateHelper_RPGOverhaul'.static.GetNewXComHQState(StartState);

	//XComHQ.BonusAbilityPointScalar *= 2.0;
	
}

static event OnLoadedSavedGame()
{
	InitializeClassInsiginiaGameState();
}


static event OnLoadedSavedGameToStrategy()
{
	InitializeClassInsiginiaGameState();
	class'X2TemplateHelper_RPGOverhaul'.static.UpdateStorage();
}

static function InitializeClassInsiginiaGameState()
{

	local XComGameStateHistory History;
	local XComGameState NewGameState;

	History = `XCOMHISTORY;
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Create ClassInsignia State");
	class'XComGameState_CustomClassInsignia'.static.CreateGameState(NewGameState);
	
	if (NewGameState.GetNumGameStateObjects() > 0)
	{
		History.AddGameStateToHistory(NewGameState);
	}
	else
	{
		History.CleanupPendingGameState(NewGameState);
	}
}

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	class'X2TemplateHelper_RPGOverhaul'.static.FinalizeUnitAbilities(UnitState, SetupData, StartState, PlayerState, bMultiplayerDisplay);
}

// <summary>
// Called from XComGameState_Unit:CanAddItemToInventory & UIArmory_Loadout:GetDisabledReason
// defaults to using the wrapper function below for calls from XCGS_U. Return false with a non-empty string in this function to show the disabled reason in UIArmory_Loadout
// Note: due to how UIArmory_Loadout does its check, expect only Slot, ItemTemplate, and UnitState to be filled when trying to fill out a disabled reason. Hence the check for CheckGameState == none
// </summary>
static function bool CanAddItemToInventory_CH(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, optional XComGameState CheckGameState, optional out string DisabledReason)
{
	//	Weapon restrictions
	if (`SecondWaveEnabled('RPGO_SWO_WeaponRestriction') && class'X2SecondWaveConfigOptions'.static.HasLimitedSpecializations())
	{
		return class'X2TemplateHelper_RPGOverhaul'.static.CanAddItemToInventory_WeaponRestrictions(bCanAddItem, Slot, ItemTemplate, Quantity, UnitState, CheckGameState, DisabledReason);
	}
	else return class'X2TemplateHelper_RPGOverhaul'.static.CanAddItemToInventory(bCanAddItem, Slot, ItemTemplate, Quantity, UnitState, CheckGameState, DisabledReason);
}

static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
	class'X2TemplateHelper_RPGOverhaul'.static.UpdateAnimations(CustomAnimSets, UnitState, Pawn);
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local string PossibleValue;

	PossibleValue = class'RPGOAbilityConfigManager'.static.GetConfigTagValue(InString);
	if (PossibleValue != "")
	{
		OutString = PossibleValue;
		return true;
	}

	return false;
}

static function bool AbilityTagExpandHandler_CH(string InString, out string OutString, Object ParseObj, Object StrategyParseOb, XComGameState GameState)
{
	//local XComGameStateHistory History;
	//local XComGameState_Effect EffectState;
	//local XComGameState_Ability AbilityState;
	//local X2AbilityTemplate AbilityTemplate;
	//
	//
	//History = `XCOMHISTORY;
	//
	//EffectState = XComGameState_Effect(ParseObj);
	//AbilityState = XComGameState_Ability(ParseObj);
	//AbilityTemplate = X2AbilityTemplate(ParseObj);
	//
	////`LOG(GetFuncName() @ InString @ "1" @ EffectState @ AbilityState @ AbilityTemplate,, 'RPGO');
	//
	//if (EffectState != none)
	//{
	//	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	//}
	//if (AbilityState != none)
	//{
	//	AbilityTemplate = AbilityState.GetMyTemplate();
	//}

	//`LOG(GetFuncName() @ InString @ "2" @ EffectState @ AbilityState @ AbilityTemplate,, 'RPGO');
		
	return false;
}


//exec function RPGO_DebugSpecListIcons(
//	int ItemHeight,
//	int IconSize,
//	int InitPosX,
//	int InitPosY,
//	int IconPadding,
//	string BGColor,
//	string FGColor
//)
//{
//	local UIChooseSpecializations UI;
//	local UIInventory_SpecializationListItem Item;
//	local int Index, IconIndex;
//
//	UI = UIChooseSpecializations(`SCREENSTACK.GetFirstInstanceOf(class'UIChooseSpecializations'));
//	for (Index = 0; Index < UI.PoolList.GetItemCount(); Index++)
//	{
//		Item = UIInventory_SpecializationListItem(UI.PoolList.GetItem(Index));
//		Item.SetHeight(ItemHeight);
//		Item.InitPosX = InitPosX;
//		Item.InitPosY = InitPosY;
//		Item.IconSize = IconSize;
//		Item.EDGE_PADDING = IconPadding;
//		Item.ConfirmButton.SetY(InitPosY);
//		Item.RealizeSpecializationsIcons();
//		for (IconIndex = 0; IconIndex < Item.SpecializationAbilityIcons.Length; IconIndex++)
//		{
//			Item.SpecializationAbilityIcons[IconIndex].SetBGColor(BGColor);
//			Item.SpecializationAbilityIcons[IconIndex].SetForegroundColor(FGColor);
//		}
//		//Item.PopulateData();
//		
//		//Item.RealizeLocation();
//		//Item.InitPanel();
//	}
//	UI.PoolList.RealizeItems();
//	UI.PoolList.RealizeList();
//}
