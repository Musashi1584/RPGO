class X2DownloadableContentInfo_XCOM2RPGOverhaul extends X2DownloadableContentInfo config(RPG);

var config array<string> RunBefore;
var config array<string> RunAfter;
var config array<string> IncompatibleMods;
var config array<string> RequiredMods;
var config string DisplayName;

function array<string> GetRunBeforeDLCIdentifiers()
{
	return default.RunBefore;
}

function array<string> GetRunAfterDLCIdentifiers()
{
	return default.RunAfter;
}

function array<string> GetIncompatibleDLCIdentifiers()
{
	return default.IncompatibleMods;
}

function array<string> GetRequiredDLCIdentifiers()
{
	return default.RequiredMods;
}

function string GetDisplayName()
{
	return default.DisplayName;
}

// Double tactical ability points
static event InstallNewCampaign(XComGameState StartState)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = class'X2TemplateHelper_RPGOverhaul'.static.GetNewXComHQState(StartState);

	XComHQ.BonusAbilityPointScalar *= 2.0;
	
}

static event OnLoadedSavedGameToStrategy()
{
	class'X2TemplateHelper_RPGOverhaul'.static.UpdateStorage();
}

static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	class'X2TemplateHelper_RPGOverhaul'.static.FinalizeUnitAbilities(UnitState, SetupData, StartState, PlayerState, bMultiplayerDisplay);
}

static event OnPostTemplatesCreated()
{
	`LOG(default.class @ GetFuncName(),, 'DLCSort');
	class'X2TemplateHelper_RPGOverhaul'.static.AddSecondWaveOption(
		'RPGOSpecRoulette',
		class'XGLocalizedData_RPG'.default.strSWO_SpecRoulette_Description,
		class'XGLocalizedData_RPG'.default.strSWO_SpecRoulette_Tooltip
	);
	
	class'X2TemplateHelper_RPGOverhaul'.static.AddSecondWaveOption(
		'RPGOCommandersChoice',
		class'XGLocalizedData_RPG'.default.strSWO_CommandersChoice_Description,
		class'XGLocalizedData_RPG'.default.strSWO_CommandersChoice_Tooltip
	);

	class'X2TemplateHelper_RPGOverhaul'.static.AddSecondWaveOption(
		'RPGOTrainingRoulette',
		class'XGLocalizedData_RPG'.default.strSWO_TrainingRoulette_Description,
		class'XGLocalizedData_RPG'.default.strSWO_TrainingRoulette_Tooltip
	);
	
	

	class'X2SoldierClassTemplatePlugin'.static.SetupSpecialization('UniversalSoldier');
	class'X2TemplateHelper_RPGOverhaul'.static.PatchAcademyUnlocks('UniversalSoldier');
	class'X2TemplateHelper_RPGOverhaul'.static.PatchAbilityPrerequisites();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchAbilitiesWeaponCondition();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchWeapons();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchHolotargeting();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchSquadSight();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchSniperStandardFire();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchStandardShot();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchRemoteStart();
	class'X2TemplateHelper_RPGOverhaul'.static.PatchLongWatch();
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
}

// <summary>
// Called from XComGameState_Unit:CanAddItemToInventory & UIArmory_Loadout:GetDisabledReason
// defaults to using the wrapper function below for calls from XCGS_U. Return false with a non-empty string in this function to show the disabled reason in UIArmory_Loadout
// Note: due to how UIArmory_Loadout does its check, expect only Slot, ItemTemplate, and UnitState to be filled when trying to fill out a disabled reason. Hence the check for CheckGameState == none
// </summary>
static function bool CanAddItemToInventory_CH(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, optional XComGameState CheckGameState, optional out string DisabledReason)
{
	return class'X2TemplateHelper_RPGOverhaul'.static.CanAddItemToInventory(bCanAddItem, Slot, ItemTemplate, Quantity, UnitState, CheckGameState, DisabledReason);
}

static function UpdateAnimations(out array<AnimSet> CustomAnimSets, XComGameState_Unit UnitState, XComUnitPawn Pawn)
{
	class'X2TemplateHelper_RPGOverhaul'.static.UpdateAnimations(CustomAnimSets, UnitState, Pawn);
}

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local name Type;

	Type = name(InString);
	switch(Type)
	{
		case 'SENTINEL_LW_USES_PER_TURN':
			OutString = string(class'X2Effect_LW2WotC_Sentinel'.default.SENTINEL_LW_USES_PER_TURN + 1);
			return true;
		case 'HEAT_WARHEADS_PIERCE':
			OutString = string(class'X2Ability_LW2WotC_PassiveAbilitySet'.default.HEAT_WARHEADS_PIERCE);
			return true;
		case 'HEAT_WARHEADS_SHRED':
			OutString = string(class'X2Ability_LW2WotC_PassiveAbilitySet'.default.HEAT_WARHEADS_SHRED);
			return true;
		default: 
			return false;
	}
}
