class UIAbilityIconRow extends UIPanel;

var int EDGE_PADDING;
var int InitPosX;
var int InitPosY;
var int IconSize;

var array<UIIcon> AbilityIcons;

simulated function PopulateIcons(
	array<X2AbilityTemplate> Templates,
	optional int InIconSize = -1
)
{
	local X2AbilityTemplate Template;
	local int Index, IconStartX, IconStartY;
	local UIIcon PerkIcon;

	if (InIconSize >= 0)
	{
		IconSize = InIconSize;
	}

	IconStartX = InitPosX + EDGE_PADDING;
	IconStartY = InitPosY + EDGE_PADDING - IconSize;

	for (Index = AbilityIcons.Length - 1; Index >= 0; Index--)
	{
		AbilityIcons[Index].Remove();
		AbilityIcons.Remove(Index, 1);
	}

	Index = 0;
	foreach Templates(Template)
	{
		PerkIcon = Spawn(class'UIIcon', self);
		PerkIcon.bAnimateOnInit = false;
		PerkIcon.bDisableSelectionBrackets = true;
		PerkIcon.InitIcon('', Template.IconImage, true, true, IconSize);
		//PerkIcon.ProcessMouseEvents(OnChildMouseEvent);
		PerkIcon.SetPosition(
			PosOffsetX(Index, IconStartX, IconSize, EDGE_PADDING),
			PosOffsetY(Index, IconStartY, IconSize, EDGE_PADDING)
		);
		PerkIcon.SetTooltipText(
			Template.GetMyLongDescription(),
			Template.LocFriendlyName
			, 25, 20,,, true, 0.1
		);

		PerkIcon.SetBGColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
		PerkIcon.SetForegroundColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);

		AbilityIcons.AddItem(PerkIcon);
		
		Index++;
	}
}

simulated function int PosOffsetX(int Index, int IconStartX, int IconWidhtHeight, int Spacing)
{
	return Index * (IconWidhtHeight + Spacing) + IconStartX;
}

simulated function int PosOffsetY(int Index, int IconStartY, int IconWidhtHeight, int Spacing)
{
	return IconStartY + Spacing; // + Index * (IconWidhtHeight + Spacing);
}

defaultproperties
{
	EDGE_PADDING = 15
	InitPosX = 0
	InitPosY = 0
	IconSize = 32
	Width = 300
}