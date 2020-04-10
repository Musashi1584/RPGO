class UIStartingAbilitiesIconList extends UIPanel;

var UIPanel StartingAbiltiesBG;
var UIX2PanelHeader StartingAbiltiesHeader;
var UIAbilityIconRow AbilityIconRow;
var int IconSize;
var localized string m_strStartingAbilities;

simulated function UIPanel InitStartingAbilitiesIconList(
	optional name InitName,
	optional name InitLibID,
	optional XComGameState_Unit UnitState
)
{
	local array<X2AbilityTemplate> Templates;
	local string HeaderTitle;
	super.InitPanel(InitName, InitLibID);

	StartingAbiltiesBG = Spawn(class'UIPanel', self);
	StartingAbiltiesBG.InitPanel('BG', class'UIUtilities_Controls'.const.MC_X2Background);

	HeaderTitle = default.m_strStartingAbilities;
	if (`ISCONTROLLERACTIVE)
	{
		HeaderTitle = class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_LSCLICK_L3, 28, 28) @ HeaderTitle;
	}
	StartingAbiltiesHeader = Spawn(class'UIX2PanelHeader', self);
	StartingAbiltiesHeader.InitPanelHeader('StartingAbiltiesHeader', HeaderTitle);
	StartingAbiltiesHeader.SetPosition(10, 10);

	Templates = class'X2SoldierClassTemplatePlugin'.static.GetAbilityTemplatesForRank(UnitState, 0);

	AbilityIconRow = Spawn(class'UIAbilityIconRow', self);
	AbilityIconRow.BlackBracket = false;
	AbilityIconRow.TooltipAnchor = class'UIUtilities'.const.ANCHOR_BOTTOM_LEFT;
	ABilityIconRow.ControllerTooltipAnchor = class'UIUtilities'.const.ANCHOR_BOTTOM_CENTER;
	ABilityIconRow.ToolTipY = Y;
	AbilityIconRow.InitAbilityIconRowPanel('StartingAbilitiesIconRow',, IconSize, Templates);
	AbilityIconRow.SetY(75);

	StartingAbiltiesBG.SetWidth(Max(AbilityIconRow.Width + 15, Width));
	StartingAbiltiesBG.SetHeight(AbilityIconRow.Y + AbilityIconRow.Height + 20);
	StartingAbiltiesHeader.SetHeaderWidth(StartingAbiltiesBG.Width - 20);

	return self;
}

simulated function SetY(float NewY)
{
	super.SetY(NewY);
	ABilityIconRow.ToolTipY = NewY;
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	AbilityIconRow.OnSelectionChanged(0);
}

simulated function AnimateIn(optional float Delay = 0)
{
	StartingAbiltiesBG.AnimateIn(Delay + class'UIUtilities'.const.INTRO_ANIMATION_TIME);
	Delay += class'UIUtilities'.const.INTRO_ANIMATION_TIME;

	StartingAbiltiesHeader.AnimateIn(Delay + class'UIUtilities'.const.INTRO_ANIMATION_TIME);
	Delay += class'UIUtilities'.const.INTRO_ANIMATION_TIME;

	AbilityIconRow.AnimateIn(Delay + class'UIUtilities'.const.INTRO_ANIMATION_TIME);
	Delay += class'UIUtilities'.const.INTRO_ANIMATION_TIME;
}

simulated function CenterIcons()
{
	AbilityIconRow.SetX(
		(StartingAbiltiesBG.Width - AbilityIconRow.Width) / 2
	);
}

defaultproperties
{
	//bIsNavigable = false
	bAnimateOnInit = true
	Width = 300
	IconSize = 32
}