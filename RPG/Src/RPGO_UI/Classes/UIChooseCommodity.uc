class UIChooseCommodity extends UIInventory;

var array<Commodity>		CommodityPool;
var array<Commodity>		CommoditiesChosen;

var int MaxChooseItem, ConfirmButtonOffset;
var array<Commodity> OwnedItems;

var UIX2PanelHeader PoolHeader;
var UIList PoolList;
var UIX2PanelHeader ChosenHeader;
var UIList ChosenList;

var StateObjectReference UnitReference;
var class<Actor> ListItemClass;
var bool ShowSelect;

var localized string m_strTitlePool;
var localized string m_strInventoryLabelPool;
var localized string m_strTitleChosen;
var localized string m_strInventoryLabelChosen;
var localized string m_strChoose;
var localized string m_strRemove;
var localized string m_strItemChosen;
var localized string m_strItemOwned;
var localized string m_strItemLimitReached;
var localized string m_strItemNotRemovable;

delegate AcceptAbilities(UIChooseCommodity ChooseCommodityScreen);

// override in sub classes
simulated function OnContinueButtonClick();
simulated function AddToChosenList(int Index);
simulated function RemoveFromChosenList(int ChosenIndex, int PoolIndex);

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	BuildList(PoolList, PoolHeader, 'PoolList', 'PoolTitleHeader',
		120, m_strTitlePool, m_strInventoryLabelPool, eButton_LBumper);

	BuildList(ChosenList, ChosenHeader, 'ChosenList', 'ChosenTitleHeader',
		1200,  m_strTitleChosen, m_strInventoryLabelChosen, eButton_RBumper, true);

	PoolList.OnItemDoubleClicked = OnItemAdded;
	ChosenList.OnItemDoubleClicked = OnItemRemoved;

	SetBuiltLabel("");
	SetCategory("");
	ListContainer.Hide();
	ItemCard.Hide();
	
	Navigator.SetSelected(PoolList);

	//if(bIsIn3D)
	//	class'UIUtilities'.static.DisplayUI3D(DisplayTag, CameraTag, OverrideInterpTime != -1 ? OverrideInterpTime : `HQINTERPTIME);
}


simulated function InitChooseCommoditiesScreen(
	StateObjectReference UnitRef,
	int MaxItems,
	array<Commodity> OwnedCommodities,
	optional delegate<AcceptAbilities> OnAccept)
{
	UnitReference = UnitRef;
	OwnedItems = OwnedCommodities;
	MaxChooseItem = MaxItems;
	AcceptAbilities = OnAccept;
	CommoditiesChosen = OwnedItems;

	//PopulateData();
}

simulated function BuildList(out UIList CommList, out UIX2PanelHeader Header, name ListName, name HeaderName,
	int PositionX, optional string HeaderTitle = "", optional string HeaderSubtitle = "", optional eButton NavButton, optional bool NavRight)
{
	local string NavStr;

	CommList = Spawn(class'UIList', self);
	CommList.BGPaddingTop = 90;
	CommList.BGPaddingRight = 30;
	CommList.bSelectFirstAvailable = `ISCONTROLLERACTIVE;
	CommList.bPermitNavigatorToDefocus = true; // Apparently we are in the 1% who need the original behaviour, whee!
	CommList.bStickyHighlight = false;
	CommList.bAnimateOnInit = false;
	if(`ISCONTROLLERACTIVE)
	{
		CommList.OnSelectionChanged = OnItemChanged;
	}
	else
	{
		CommList.bSelectFirstAvailable = false;
	}
	CommList.InitList(ListName,
		PositionX, 230,
		568, 710,
		false, true
	);
	CommList.BG.SetAlpha(75);
	CommList.Show();
	
	if (NavButton != eButton_None && `ISCONTROLLERACTIVE)
	{
		NavStr = class'UIUtilities_Text'.static.InjectImage(class'UIUtilities_Image'.static.GetButtonName(NavButton), 56, 28);
		if(NavRight)
		{
			HeaderTitle @= NavStr;
		}
		else
		{
			HeaderTitle = NavStr @ HeaderTitle;
		}
	}

	Header = Spawn(class'UIX2PanelHeader', self);  
	Header.bAnimateOnInit = false;
	Header.InitPanelHeader(HeaderName, HeaderTitle, HeaderSubtitle);
	Header.SetPosition(PositionX, 150);
	Header.SetHeaderWidth(588);
	Header.Show();
}

function OnItemChanged(UIList ContainerList, int ItemIndex)
{
	if(	ShowSelect != UIInventory_CommodityListItem(ContainerList.GetSelectedItem()).ConfirmButton.bIsVisible)
	{
		ShowSelect = !ShowSelect;
		UpdateNavHelp();
	}
}

simulated function PopulateData()
{
	PopulateChosen();
	PopulatePool();
	UpdateButton();
}

simulated function PopulatePool()
{
	local Commodity Template;
	local int i;
	local UIInventory_CommodityListItem Item;

	PoolList.ClearItems();
	for(i = 0; i < CommodityPool.Length; i++)
	{
		Template = CommodityPool[i];
		Item = UIInventory_CommodityListItem(Spawn(ListItemClass, PoolList.ItemContainer));
		Item.AutoNavigable = true;
		Item.InitInventoryListCommodity(Template, , m_strChoose, , , ConfirmButtonOffset);
		UpdatePoolListItem(Item);
	}
	if(PoolList.bSelectFirstAvailable)
	{
		PoolLIst.SelectedIndex = INDEX_NONE;
		PoolList.Navigator.SelectFirstAvailable();
	}
}

simulated function PopulateChosen()
{
	local Commodity Template;
	local int i, SelectedIndex;
	local UIInventory_CommodityListItem Item;

	SelectedIndex = clamp(ChosenList.SelectedIndex, 0, CommoditiesChosen.Length-1);
	ChosenList.ClearItems();
	for(i = 0; i < CommoditiesChosen.Length; i++)
	{
		Template = CommoditiesChosen[i];
		Item = UIInventory_CommodityListItem(Spawn(ListItemClass, ChosenList.ItemContainer));
		Item.InitInventoryListCommodity(Template, , m_strRemove, , , ConfirmButtonOffset);
		UpdateChosenListItem(Item);
	}

	if (`ISCONTROLLERACTIVE)
	{
		if (CommoditiesChosen.Length != 0)
		{
			ChosenList.SetSelectedIndex(SelectedIndex);
			if(!ChosenList.IsSelectedNavigation())
			{
				// Mr. Nice: SetSelectedIndex() calls OnRecieveFocus() for that index,
				// we don't want that if the ChosenList isn't the current navigation list! so undo it...
				ChosenList.OnLoseFocus();
			}
		}
		else if(ChosenList.IsSelectedNavigation())
		{
			SwitchList(PoolList, ChosenList, false);
		}
	}

	ChosenHeader.SetText(m_strTitleChosen @ CommoditiesChosen.Length - OwnedItems.Length $ "/" $ MaxChooseItem, m_strInventoryLabelChosen);
}

simulated function UpdatePoolList()
{
	local int Index;
	local float SBPos;
	local bool NoSelection;

	NoSelection = PoolList.SelectedIndex == INDEX_NONE;
	if (PoolList.Scrollbar != none)
	{
		SBPos = PoolList.Scrollbar.percent;
	}

	for (Index = 0; Index < PoolList.GetItemCount(); Index++)
	{
		UpdatePoolListItem(UIInventory_CommodityListItem(PoolList.GetItem(Index)));
	}

	// Mr. Nice: Enabling and Disabling navigation can mess up navigation order vs actual list order
	PoolList.Navigator.NavigableControls.Sort(PoolListIndexOrder);

	if(`ISCONTROLLERACTIVE)
	{
		if(PoolList.Navigator.Size == 0 && PoolList.IsSelectedNavigation())
		{
			PoolList.SetSelectedIndex(INDEX_NONE);
			PoolList.Scrollbar.SetThumbAtPercent(SBPos);
			SwitchList(ChosenList, PoolList, false);
		}
		else if (NoSelection)
		{
		// Mr. Nice: this *should* mean we are currently navigating the chosen list,
		// defer resolving "correct" selection until we navigate back to the pool list.
		// UpdatePoolListItem activity will almost certainly have "validated" the selection...
			PoolList.SetSelectedIndex(INDEX_NONE);
		}
	}
	else
	{
		// Mr. Nice: get slight flicker on choosing otherwise, as the next item becomes selected
		// (because we just disabled navigation), but then on the next the just chosen item gets the green highlight...
		// (because the mouse is over it, and the mouse doesn't care about navigation status!)
		PoolList.OnLoseFocus();
		PoolList.Scrollbar.SetThumbAtPercent(SBPos);
	}
}

simulated function UpdateChosenList()
{
	local int Index;

	for (Index = 0; Index < ChosenList.GetItemCount(); Index++)
	{
		UpdateChosenListItem(UIInventory_CommodityListItem(ChosenList.GetItem(Index)));
	}
}

simulated function UpdatePoolListItem(UIInventory_CommodityListItem Item)
{
	local int Index;

	Index = GetItemIndex(Item.ItemComodity);

	// Mr. Nice: Order of disable/good state setting avoids any chance of an item having
	// it's navigation status toggled twice, minimizes chances of selection changing
	// unexepectedly for controllers
	if (HasReachedSpecLimit())
	{
		// For whatever reason, disabling while good then then taking of good doesn't update correctly
		// Since *every* item is going disabled though, the navigation order issues are irrelevant,
		// so ok if picked items technically become navigable again during the update.
		Item.ShouldShowGoodState(false);
		Item.DisableListItem(m_strItemLimitReached);
	}
	else if (IsOwnedSpec(Index))
	{
		Item.DisableListItem();
		Item.ShouldShowGoodState(false, m_strItemOwned);
	}
	else if (IsPicked(Index))
	{
		Item.ShouldShowGoodState(true);
		Item.SetDisabled(false, m_strItemChosen);
	}
	else
	{
		Item.EnableListItem();
		Item.ShouldShowGoodState(false);
	}
}

simulated function UpdateChosenListItem(UIInventory_CommodityListItem Item)
{
	Item.EnableListItem();
	Item.ShouldShowGoodState(false);

	if (IsOwnedSpec(GetItemIndex(Item.ItemComodity)))
		Item.ShouldShowGoodState(true, m_strItemNotRemovable);
}

function int PoolListIndexOrder(UIPanel FirstItem, UIPanel SecondItem)
{
	return PoolList.GetItemIndex(SecondItem) - PoolList.GetItemIndex(FirstItem);
}

simulated function UpdateButton()
{
	local UINavigationHelp NavHelp;

	NavHelp = `HQPRES.m_kAvengerHUD.NavHelp;

	if (HasReachedSpecLimit())
	{
		NavHelp.ContinueButton.EnableButton();
	}
	else
	{
		NavHelp.ContinueButton.DisableButton();
	}
}

simulated function bool IsPicked(int Index)
{
	return CommoditiesChosen.Find('Title', CommodityPool[Index].Title) != INDEX_NONE;
}

simulated function bool IsOwnedSpec(int Index)
{
	return OwnedItems.Find('Title', CommodityPool[Index].Title) != INDEX_NONE;
}

simulated function bool HasReachedSpecLimit()
{
	return CommoditiesChosen.Length - OwnedItems.Length >= MaxChooseItem;
}

simulated function int GetItemIndex(Commodity Item)
{
	local int i;

	for(i = 0; i < CommodityPool.Length; i++)
	{
		if(CommodityPool[i] == Item)
		{
			return i;
		}
	}

	return -1;
}

simulated function UpdateAll()
{
	UpdatePoolList();
	PopulateChosen();
	UpdateButton();
}

simulated function OnItemAdded(UIList kList, int itemIndex)
{
	if (!(HasReachedSpecLimit() || IsPicked(itemIndex)))
	{
		AddToChosenList(itemIndex);
		UpdateAll();
		PlayPositiveSound();
	}
	else
	{
		PlayNegativeSound();
	}
}

simulated function OnItemRemoved(UIList kList, int itemIndex)
{
	local int PoolIndex;
	
	PoolIndex = GetItemIndex(UIInventory_CommodityListItem(ChosenList.GetItem(itemIndex)).ItemComodity);

	if (!IsOwnedSpec(PoolIndex))
	{
		RemoveFromChosenList(itemIndex, PoolIndex);
		UpdateAll();
		PlayPositiveSound();
	}
	else
	{
		PlayNegativeSound();
	}
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return false;
	// Only pay attention to presses or repeats; ignoring other input types
	// NOTE: Ensure repeats only occur with arrow keys

	switch (cmd)
	{
	case class'UIUtilities_Input'.const.FXS_BUTTON_X :
		OnContinueButtonClick();
		bHandled = true;
		break;

	case class'UIUtilities_Input'.const.FXS_BUTTON_LBUMPER :
	//case class'UIUtilities_Input'.const.FXS_ARROW_LEFT:
	//case class'UIUtilities_Input'.const.FXS_DPAD_LEFT:
	//case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_LEFT:
		SwitchList(PoolList, ChosenList);
		bHandled = true;
		break;

	case class'UIUtilities_Input'.const.FXS_BUTTON_RBUMPER :
	//case class'UIUtilities_Input'.const.FXS_ARROW_RIGHT:
	//case class'UIUtilities_Input'.const.FXS_DPAD_RIGHT:
	//case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_RIGHT:
		SwitchList(ChosenList, PoolList);
		bHandled = true;
		break;

	case class'UIUtilities_Input'.const.FXS_ARROW_DOWN:
	case class'UIUtilities_Input'.const.FXS_DPAD_DOWN:
	case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_DOWN:
	case class'UIUtilities_Input'.const.FXS_ARROW_UP:
	case class'UIUtilities_Input'.const.FXS_DPAD_UP:
	case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_UP:
		// Mr. Nice: Stop Navigator getting confused, which it is when there are less than 2 items...
		bHandled = (PoolList.IsSelectedNavigation() ? PoolList : ChosenList).Navigator.Size <= 1;
		break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

function bool SwitchList(UIList ToList, UIList FromList, optional bool UISound=true)
{
	local float SBPos;

	if(ToList.IsSelectedNavigation())
	{
		return false;
	}

	if(ToList.Navigator.Size != 0)
	{
		if (ToList.SelectedIndex == INDEX_NONE)
		{
			if (PoolList.Scrollbar != none)
			{
				SBPos = PoolList.Scrollbar.percent;
			}
			ToList.SetSelectedIndex((ToList.ItemCount - 1) * SBPos);
			if (!ToList.GetSelectedItem().bIsNavigable)
			{
				// Mr. Nice: quick dirty way of getting a valid selection while some what minimizing
				// scroll position change.
				ToList.NavigatorSelectionChanged((ToList.Navigator.Size - 1) * SBPos);
			}
		}
		ToList.SetSelectedNavigation();
		FromList.OnLoseFocus();
		if(`ISCONTROLLERACTIVE)
			OnItemChanged(ToList,ToList.SelectedIndex);
		if(UISound)
		{
			PlayNavSound();
		}
		return true;
	}
	else if(UISound)
	{
		PlayNegativeSound();
	}
	return false;
}

simulated function UpdateNavHelp()
{
	local UINavigationHelp NavHelp;
	local int iconYOffset;

	NavHelp = `HQPRES.m_kAvengerHUD.NavHelp;

	NavHelp.ClearButtonHelp();
	NavHelp.bIsVerticalHelp = `ISCONTROLLERACTIVE;
	NavHelp.AddBackButton(OnCancel);
	if (ShowSelect) NavHelp.AddSelectNavHelp();
	NavHelp.AddContinueButton(OnContinueButtonClick);

	if(`ISCONTROLLERACTIVE)
	{
		if( GetLanguage() == "JPN" ) 
		{
			iconYOffset = -10;
		}
		else if( GetLanguage() == "KOR" )
		{
			iconYOffset = -20;
		}
		else
		{
			iconYOffset = -15;
		}
		NavHelp.ContinueButton.SetText(class'UIUtilities_Text'.static.InjectImage(
			class'UIUtilities_Image'.static.GetButtonName(eButton_X), 28, 28, iconYOffset) @ class'UIUtilities_Text'.default.m_strGenericContinue);
	}
}

simulated function PlayPositiveSound()
{
	class'UIUtilities_Sound'.static.PlayPositiveSound();
}

simulated function PlayNegativeSound()
{
	class'UIUtilities_Sound'.static.PlayNegativeSound();
}

simulated function PlayNavSound()
{
	PlaySound( SoundCue'SoundUI.MenuScrollCue', true );
}

simulated function RefreshFacility()
{
	local UIScreen QueueScreen;

	QueueScreen = Movie.Stack.GetScreen(class'UIFacility_Academy');
	if (QueueScreen != None)
		UIFacility_Academy(QueueScreen).RealizeFacility();
}

simulated function OnCancelButton(UIButton kButton) { OnCancel(); }
simulated function OnCancel()
{
	super.OnCancel();
	Movie.Stack.PopFirstInstanceOfClass(class'UIArmory');
}

simulated function XComGameState_Unit GetUnit()
{
	return XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
}
//==============================================================================

simulated function OnLoseFocus()
{
	super.OnLoseFocus();
	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();
	UpdateNavHelp();
}

defaultproperties
{
	ListItemClass = class'UIInventory_CommodityListItem'
	ConfirmButtonOffset = 126

	bAutoSelectFirstNavigable = false
	bHideOnLoseFocus = true
	ShowSelect = true;

	InputState = eInputState_Consume
	
	DisplayTag = "UIBlueprint_Promotion"
	CameraTag = "UIBlueprint_Promotion"
}