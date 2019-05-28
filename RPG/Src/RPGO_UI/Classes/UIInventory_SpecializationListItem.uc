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

simulated function RefreshConfirmButtonVisibility()
{
	if( ConfirmButton != none )
	{
		if( bIsFocused )
		{
			// initially it seems as though the visible flag gets stuck to true when it hasn't displayed yet. Turn off and on again.
			ConfirmButton.SetVisible(false);
			ConfirmButton.SetVisible(!bIsBad && !bDisabled && !bIsGood);
			if( bIsBad || bDisabled )
			{
				SetRightColPadding( AttentionIconPadding + ConfirmButtonStoredRightCol );
			}
			else
			{
				SetRightColPadding(ConfirmButton.Width + ConfirmButtonArrowWidth + AttentionIconPadding + ConfirmButtonStoredRightCol);
			}
			if( `ISCONTROLLERACTIVE )
			{
				ConfirmButton.OnReceiveFocus();
			}
		}
		else
		{
			ConfirmButton.SetVisible(false);
			SetRightColPadding(ConfirmButtonStoredRightCol + AttentionIconPadding);
			if( `ISCONTROLLERACTIVE )
			{
				ConfirmButton.OnLoseFocus();
			}
		}
	}
	else
	{
		SetRightColPadding(ConfirmButtonStoredRightCol + AttentionIconPadding);
	}
}