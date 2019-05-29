class UIInventory_AbilityListItem extends UIInventory_CommodityListItem;

var UIIcon IconPanel;
var privatewrite int IconSize;

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	super.InitPanel(InitName, InitLibID);

	IconPanel = Spawn(class'UIIcon', Self, 'perkIcon');
	IconPanel.bIsNavigable = false;
	IconPanel.InitIcon('perkIcon',,,, IconSize);
	IconPanel.SetX(RightColDefaultPadding + 10);
	IconPanel.SetY((Height - IconSize) / 2);

	RefreshIcon();

	return self;
}

simulated function RefreshIcon()
{
	IconPanel.SetBGColorState(eUIState_Normal);
	IconPanel.LoadIcon(ItemComodity.Image);
}

simulated function PopulateData(optional bool bRealizeDisabled)
{
	MC.BeginFunctionOp("populateData");
	//MC.QueueString(ItemComodity.Image);
	MC.QueueString("");
	MC.QueueString(ItemComodity.Title);
	if (ItemComodity.OrderHours > -1)
	{
		MC.QueueString(class'UIUtilities_text'.static.GetTimeRemainingString(ItemComodity.OrderHours));
	}
	else
	{
		MC.QueueString("");
	}
	MC.QueueString(ItemComodity.Desc);
	MC.EndOp();

	if(bRealizeDisabled)
		RealizeDisabledState();
}

defaultproperties
{
	IconSize = 56
	Height = 130
}