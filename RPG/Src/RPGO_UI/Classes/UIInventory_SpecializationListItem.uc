class UIInventory_SpecializationListItem extends UIInventory_ClassListItem;

simulated function PopulateData(optional bool bRealizeDisabled)
{
	MC.BeginFunctionOp("populateData");
	MC.QueueString(ItemComodity.Image);
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

simulated function UIListItemString SetDisabled(bool disabled, optional string TooltipText)
{
	Super.SetDisabled(disabled, TooltipText);
	UpdateNavigation();
	return self;
}

simulated function ShouldShowGoodState(bool isGood, optional string TooltipText)
{
	Super.ShouldShowGoodState(isGood, TooltipText);
	UpdateNavigation();
}

simulated function UpdateNavigation()
{
	if (bDisabled || bIsGood)
	{
		 DisableNavigation();
	}
	else
	{
		EnableNavigation();
	}
}