class UIInventory_AbilityListItem extends UIInventory_ClassListItem;

var UIIcon IconPanel;
var X2AbilityTemplate Template;
var privatewrite int IconSize;

simulated function InitInventoryListAbility(X2AbilityTemplate AbilityTemplate,
											  Commodity initCommodity, 
											  optional StateObjectReference InitItemRef, 
											  optional string Confirm, 
											  optional EUIConfirmButtonStyle InitConfirmButtonStyle = eUIConfirmButtonStyle_Default,
											  optional int InitRightCol,
											  optional int InitHeight,
											  optional bool bIsPsi)
{
	Template = AbilityTemplate;
	
	super.InitInventoryListCommodity(initCommodity, InitItemRef, Confirm, InitConfirmButtonStyle, InitRightCol, InitHeight, bIsPsi);
}


simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	super.InitPanel(InitName, InitLibID);

	IconPanel = Spawn(class'UIIcon', Self, 'perkIcon');
	IconPanel.InitIcon('perkIcon',,,, IconSize);
	IconPanel.SetX(RightColDefaultPadding + 10);
	IconPanel.SetY((Height - IconSize) / 2);

	RefreshIcon();

	return self;
}

simulated function RefreshIcon()
{
	IconPanel.SetBGColorState(eUIState_Normal);
	IconPanel.LoadIcon(Template.IconImage);
	//UIAbilityPopup;
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

defaultproperties
{
	IconSize = 56
	Height = 130
}