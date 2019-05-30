class UIStartingAbilities extends UIPanel;

var UIPanel StartingAbiltiesBG;
var UIX2PanelHeader StartingAbiltiesHeader;
var UIAbilityIconRow AbilityIconRow;

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{


	return super.InitPanel(InitName, InitLibID);
}

simulated function InitStartingAbilities(XComGameState_Unit UnitState)
{
	local array<X2AbilityTemplate> Templates;

	Templates = class'X2SoldierClassTemplatePlugin'.static.GetAbilityTemplatesForRank(UnitState, 0);

	StartingAbiltiesBG = Spawn(class'UIPanel', self);
	StartingAbiltiesBG.InitPanel('BG', class'UIUtilities_Controls'.const.MC_X2Background);
	//StartingAbiltiesBG.SetWidth(Width);

	StartingAbiltiesHeader = Spawn(class'UIX2PanelHeader', self);
	StartingAbiltiesHeader.InitPanelHeader('StartingAbiltiesHeader', "Starting Abilities");
	StartingAbiltiesHeader.SetHeaderWidth(Width - 20);
	StartingAbiltiesHeader.SetPosition(10, 10);

	AbilityIconRow = Spawn(class'UIAbilityIconRow', self);
	AbilityIconRow.PopulateIcons(Templates);
}