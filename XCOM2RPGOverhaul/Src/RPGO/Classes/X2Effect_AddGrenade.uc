class X2Effect_AddGrenade extends XMBEffect_AddUtilityItem config(GameData_SoldierSkills);

struct LongWarUpgradeInfo
{
	var name ResearchName;
	var name BaseItemName;
	var name ItemName;
};

var config array<LongWarUpgradeInfo> LongWarUpgrades;

var array<name> RandomGrenades;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local X2ItemTemplate ItemTemplate;
	local X2ItemTemplateManager ItemTemplateMgr;
	local XComGameState_Unit NewUnit;
	local name TemplateName;
	local LongWarUpgradeInfo Upgrade;
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = `XCOMHQ;

	NewUnit = XComGameState_Unit(kNewTargetState);
	if (NewUnit == none)
		return;

	if (class'XMBEffectUtilities'.static.SkipForDirectMissionTransfer(ApplyEffectParameters))
		return;

	ItemTemplateMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	if (RandomGrenades.Length > 0)
		TemplateName = RandomGrenades[`SYNC_RAND(RandomGrenades.Length)];
	else
		TemplateName = DataName;

	foreach LongWarUpgrades(Upgrade)
	{
		if (Upgrade.BaseItemName == TemplateName && XComHQ.IsTechResearched(Upgrade.ResearchName))
		{
			TemplateName = Upgrade.ItemName;
			break;
		}
	}

	ItemTemplate = ItemTemplateMgr.FindItemTemplate(TemplateName);
	
	// Use the highest upgraded available version of the item
	if (bUseHighestAvailableUpgrade)
		XComHQ.UpdateItemTemplateToHighestAvailableUpgrade(ItemTemplate);

	AddUtilityItem(NewUnit, ItemTemplate, NewGameState, NewEffectState);
}
