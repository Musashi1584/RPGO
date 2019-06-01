class UIAbilityIconRow extends UIPanel;

var int EDGE_PADDING;
var int InitPosX;
var int InitPosY;
var int IconSize;
var bool BlackBracket;

var array<UIIcon> AbilityIcons;

simulated function UIPanel InitAbilityIconRowPanel(
	optional name InitName,
	optional name InitLibID,
	optional int InIconSize = -1,
	optional array<X2AbilityTemplate> Templates
	)
{
	super.InitPanel(InitName, InitLibID);
	Navigator.HorizontalNavigation = true;
	Navigator.LoopSelection = true;
	SetSelectedNavigation();
	if (InIconSize >= 0)
	{
		IconSize = InIconSize;
	}

	if (Templates.Length > 0)
	{
		SetWidth((IconSize + EDGE_PADDING) * Templates.Length);
		SetHeight(IconSize + EDGE_PADDING);

		PopulateIcons(Templates, InIconSize);
	}

	return self;
}

simulated function PopulateIcons(
	array<X2AbilityTemplate> Templates,
	optional int InIconSize = -1
)
{
	local X2AbilityTemplate Template;
	local int Index, IconStartX, IconStartY;
	local UIIcon PerkIcon;

	IconStartX = InitPosX;
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
		//PerkIcon.bIsNavigable = false;
		PerkIcon.bAnimateOnInit = false;
		PerkIcon.bDisableSelectionBrackets = !`ISCONTROLLERACTIVE;
		PerkIcon.InitIcon('', Template.IconImage, true, true, IconSize);
		PerkIcon.SetPosition(
			PosOffsetX(Index, IconStartX, IconSize, EDGE_PADDING),
			PosOffsetY(Index, IconStartY, IconSize, EDGE_PADDING)
		);
		PerkIcon.SetTooltipText(
			Template.GetMyLongDescription(),
			Template.LocFriendlyName
			, 25, 20,,, true, 0.1
		);
		
		if(BlackBracket)
		{
			PerkIcon.SetBGColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
			PerkIcon.SetForegroundColor(class'UIUtilities_Colors'.const.BLACK_HTML_COLOR);
		}

		AbilityIcons.AddItem(PerkIcon);
		
		Index++;
	}
}

simulated function AnimateIn(optional float Delay = 0)
{
	local UIIcon Icon;
	
	foreach AbilityIcons(Icon)
	{
		Icon.AnimateIn(Delay + class'UIUtilities'.const.INTRO_ANIMATION_DELAY_PER_INDEX);
		Delay += class'UIUtilities'.const.INTRO_ANIMATION_DELAY_PER_INDEX;
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
	//bIsNavigable = false
	bAnimateOnInit = true
	BlackBracket = true
	bCascadeFocus = false
	bCascadeSelection = true
	EDGE_PADDING = 15
	InitPosX = 12
	InitPosY = 0
	IconSize = 32
	Width = 300
	Height = 50
}