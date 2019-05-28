class UIChooseSpecializations extends UIInventory;

var array<SoldierSpecialization> SpecializationsPool;
var array<Commodity>		CommodityPool;

var array<SoldierSpecialization> SpecializationsChosen;
var array<Commodity>		CommoditiesChosen;

var int ChooseSpecializationMax;
var array<int> SelectedItems, OwnedItems;

var UIX2PanelHeader PoolHeader;
var UIList PoolList;
var UIX2PanelHeader ChosenHeader;
var UIList ChosenList;

var StateObjectReference UnitReference;

var localized string m_strTitlePool;
var localized string m_strInventoryLabelPool;
var localized string m_strTitleChosen;
var localized string m_strInventoryLabelChosen;
var localized string m_strChoose;
var localized string m_strRemove;
var localized string m_strItemChosen;
var localized string m_strItemRandom;
var localized string m_strItemLimitReached;
var localized string m_strItemNotRemovable;

delegate AcceptAbilities(array<int> SelectedSpecialization);

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	`LOG(self.Class.name @ GetFuncName() @ InitController @ InitMovie @ InitName @ InitMovie.UI_RES_X @ InitMovie.UI_RES_Y,, 'RPG-UIChooseSpecializations');

	super.InitScreen(InitController, InitMovie, InitName);

	BuildList(PoolList, PoolHeader, 'PoolList', 'PoolTitleHeader',
		120, m_strTitlePool, m_strInventoryLabelPool, eButton_LBumper);

	BuildList(ChosenList, ChosenHeader, 'ChosenList', 'ChosenTitleHeader',
		1200,  m_strTitleChosen, m_strInventoryLabelChosen, eButton_RBumper, true);

	PoolList.OnItemDoubleClicked = OnSpecializationsAdded;
	ChosenList.OnItemDoubleClicked = OnSpecializationsRemoved;

	SpecializationsPool.Length = 0;
	SpecializationsPool = class'X2SoldierClassTemplatePlugin'.static.GetSpecializations();

	CommodityPool = ConvertToCommodities(SpecializationsPool);

	SpecializationsChosen.Length = 0;
	
	UpdateNavHelp();
	
	SetBuiltLabel("");
	SetCategory("");
	ListContainer.Hide();
	ItemCard.Hide();
	
	Navigator.SetSelected(PoolList);

	//if(bIsIn3D)
	//	class'UIUtilities'.static.DisplayUI3D(DisplayTag, CameraTag, OverrideInterpTime != -1 ? OverrideInterpTime : `HQINTERPTIME);
}


simulated function InitChooseSpecialization(StateObjectReference UnitRef ,int MaxSpecs, array<SoldierSpecialization> OwnedSpecs, optional delegate<AcceptAbilities> OnAccept)
{
	local Commodity Comm;

	`LOG(self.Class.name @ GetFuncName() @ UnitRef.ObjectID @ OwnedSpecs.Length @ MaxSpecs,, 'RPG-UIChooseSpecializations');
	UnitReference = UnitRef;
	SpecializationsChosen = OwnedSpecs;
	ChooseSpecializationMax = MaxSpecs;
	AcceptAbilities = OnAccept;
	
	CommoditiesChosen = ConvertToCommodities(SpecializationsChosen);

	foreach CommoditiesChosen(Comm)
	{
		OwnedItems.AddItem(GetItemIndex(Comm));
	}

	PopulateData();
}

simulated function XComGameState_Unit GetUnit()
{
	return XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
}

simulated function OnContinueButtonClick()
{
	local UIArmory_PromotionHero HeroScreen;
	`log(default.class @ GetFuncName() @ SelectedItems.Length,, 'RPG');

	if (SelectedItems.Length == ChooseSpecializationMax)
	{
		OnAllSpecSelected();
		
		Movie.Stack.Pop(self);
		HeroScreen = UIArmory_PromotionHero(`SCREENSTACK.GetFirstInstanceOf(class'UIArmory_PromotionHero'));
		if (HeroScreen != none)
		{
			HeroScreen.CycleToSoldier(UnitReference);
		}
	}
	else
	{
		PlayNegativeSound();
	}
}

function bool OnAllSpecSelected()
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local int Index;
	
	UnitState = GetUnit();

	foreach SelectedItems(Index)
	{
		`log(default.class @ GetFuncName() @
			"Add Specializations for" @ UnitState.SummaryString() @ 
			class'X2SoldierClassTemplatePlugin'.static.GetAbilityTreeTitle(UnitState, Index)
		,, 'RPG');
	}

	NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Ranking up Unit in chosen specs");

	class'X2SecondWaveConfigOptions'.static.BuildSpecAbilityTree(UnitState, SelectedItems, !`SecondWaveEnabled('RPGOSpecRoulette'), `SecondWaveEnabled('RPGOTrainingRoulette'));
	
	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));
	UnitState.SetUnitFloatValue('SecondWaveCommandersChoiceSpecChosen', 1, eCleanup_Never);
	
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);

	if (AcceptAbilities != none)
	{
		AcceptAbilities(SelectedItems);
	}

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("StrategyUI_Recruit_Soldier");
	
	return true;
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
	CommList.bAnimateOnInit = false;
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
 
	`LOG(self.Class.name @ GetFuncName() @ CommList @ Header,, 'RPG-UIChooseSpecializations');
}

simulated function array<Commodity> ConvertToCommodities(array<SoldierSpecialization> Specializations)
{
	local SoldierSpecialization Spec;
	local int i;
	local array<Commodity> Commodities;
	local Commodity Comm;
	local X2UniversalSoldierClassInfo Template;

	for (i = 0; i < Specializations.Length; i++)
	{
		Spec = Specializations[i];
		
		Template = new(None, string(Spec.TemplateName))class'X2UniversalSoldierClassInfo';
		
		Comm.Title = Template.ClassSpecializationTitle;
		Comm.Image = Template.ClassSpecializationIcon;
		Comm.Desc = Template.ClassSpecializationSummary;
		Comm.OrderHours = -1;
		//Comm.OrderHours = class'SpecialTrainingUtilities'.static.GetSpecialTrainingDays() * 24;

		Commodities.AddItem(Comm);
	}

	return Commodities;
}

simulated function PopulateData()
{
	PopulatePool();
	PopulateChosen();
	UpdateButton();
}

simulated function PopulatePool()
{
	local Commodity Template;
	local int i;
	local UIInventory_SpecializationListItem Item;

	`LOG(self.Class.name @ GetFuncName(),, 'RPG-UIChooseSpecializations');

	PoolList.ClearItems();
	for(i = 0; i < CommodityPool.Length; i++)
	{
		Template = CommodityPool[i];
		Item = Spawn(class'UIInventory_SpecializationListItem', PoolList.itemContainer);
		Item.InitInventoryListCommodity(Template, , m_strChoose, , , 126);
		UpdatePoolListItem(Item);
	}
	if(PoolList.bSelectFirstAvailable)
	{
		PoolList.SetSelectedIndex(0);
	}
}

simulated function UpdatePoolList()
{
	local int Index, ItemIndex;
	local float SBPos;
	local bool NoSelection;

	NoSelection = PoolList.SelectedIndex == INDEX_NONE;
	if (PoolList.Scrollbar != none)
	{
		SBPos = PoolList.Scrollbar.percent;
	}

	for (Index = 0; Index < PoolList.GetItemCount(); Index++)
	{
		UpdatePoolListItem(UIInventory_SpecializationListItem(PoolList.GetItem(Index)));
	}

	// Mr. Nice: Enabling and Disabling navigation can mess up navigation order vs actual list order
	PoolList.Navigator.NavigableControls.Sort(PoolListIndexOrder);

	if(`ISCONTROLLERACTIVE)
	{
		if(PoolList.Navigator.NavigableControls.Length == 0 && PoolList.IsSelectedNavigation())
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

function int PoolListIndexOrder(UIPanel FirstItem, UIPanel SecondItem)
{
	return PoolList.GetItemIndex(SecondItem) - PoolList.GetItemIndex(FirstItem);
}

simulated function UpdatePoolListItem(UIInventory_SpecializationListItem Item)
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
		Item.ShouldShowGoodState(false, m_strItemRandom);
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


simulated function PopulateChosen()
{
	local Commodity Template;
	local int i, SelectedIndex;
	local UIInventory_SpecializationListItem Item;

	`LOG(self.Class.name @ GetFuncName(),, 'RPG-UIChooseSpecializations');

	SelectedIndex = clamp(ChosenList.SelectedIndex, 0, CommoditiesChosen.Length-1);
	ChosenList.ClearItems();
	for(i = 0; i < CommoditiesChosen.Length; i++)
	{
		Template = CommoditiesChosen[i];
		Item = Spawn(class'UIInventory_SpecializationListItem', ChosenList.ItemContainer);
		Item.InitInventoryListCommodity(Template, , m_strRemove, , , 126);
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
}

simulated function UpdateChosenList()
{
	local int Index;

	for (Index = 0; Index < ChosenList.GetItemCount(); Index++)
	{
		UpdateChosenListItem(UIInventory_SpecializationListItem(ChosenList.GetItem(Index)));
	}
}

simulated function UpdateChosenListItem(UIInventory_SpecializationListItem Item)
{
	Item.EnableListItem();
	Item.ShouldShowGoodState(false);

	if (IsOwnedSpec(GetItemIndex(Item.ItemComodity)))
		Item.ShouldShowGoodState(true, m_strItemNotRemovable);
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
	return SelectedItems.Find(Index) != INDEX_NONE;
}

simulated function bool IsOwnedSpec(int Index)
{
	return OwnedItems.Find(Index) != INDEX_NONE;
}

simulated function bool HasReachedSpecLimit()
{
	return SelectedItems.Length >= ChooseSpecializationMax;
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

simulated function OnSpecializationsAdded(UIList kList, int itemIndex)
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

simulated function OnSpecializationsRemoved(UIList kList, int itemIndex)
{
	local int PoolIndex;
	
	PoolIndex = GetItemIndex(UIInventory_SpecializationListItem(ChosenList.GetItem(itemIndex)).ItemComodity);

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

simulated function AddToChosenList(int Index)
{
	SelectedItems.AddItem(Index);
	SpecializationsChosen.AddItem(SpecializationsPool[Index]);
	CommoditiesChosen = ConvertToCommodities(SpecializationsChosen);
}

simulated function RemoveFromChosenList(int ChosenIndex, int PoolIndex)
{
	SelectedItems.RemoveItem(PoolIndex);
	SpecializationsChosen.RemoveItem(SpecializationsChosen[ChosenIndex]);
	CommoditiesChosen = ConvertToCommodities(SpecializationsChosen);
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
	case class'UIUtilities_Input'.const.FXS_ARROW_LEFT:
	case class'UIUtilities_Input'.const.FXS_DPAD_LEFT:
	case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_LEFT:
		SwitchList(PoolList, ChosenList);
		bHandled = true;
		break;

	case class'UIUtilities_Input'.const.FXS_BUTTON_RBUMPER :
	case class'UIUtilities_Input'.const.FXS_ARROW_RIGHT:
	case class'UIUtilities_Input'.const.FXS_DPAD_RIGHT:
	case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_RIGHT:
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
		bHandled = (PoolList.IsSelectedNavigation() ? PoolList : ChosenList).Navigator.NavigableControls.Length <= 1;
		break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

function SwitchList(UIList ToList, UIList FromList, optional bool UISound=true)
{
	local float SBPos;

	if(ToList.IsSelectedNavigation())
	{
		return;
	}

	if(ToList.Navigator.NavigableControls.Length != 0)
	{
		`log(`showvar(ToList.SelectedIndex));
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
				ToList.NavigatorSelectionChanged((ToList.Navigator.NavigableControls.Length - 1) * SBPos);
			}
		}
		ToList.SetSelectedNavigation();
		FromList.OnLoseFocus();

		if(UISound)
		{
			PlayNavSound();
		}
	}
	else if(UISound)
	{
		PlayNegativeSound();
	}
}

simulated function UpdateNavHelp()
{
	local UINavigationHelp NavHelp;
	local int iconYOffset;

	NavHelp = `HQPRES.m_kAvengerHUD.NavHelp;

	NavHelp.ClearButtonHelp();
	NavHelp.bIsVerticalHelp = `ISCONTROLLERACTIVE;
	NavHelp.AddBackButton(OnCancel);
	NavHelp.AddSelectNavHelp();
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
	CloseScreen();
	Movie.Stack.PopFirstInstanceOfClass(class'UIArmory');
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
	bAutoSelectFirstNavigable = false
	bHideOnLoseFocus = true
	
	InputState = eInputState_Consume
	
	DisplayTag = "UIBlueprint_Promotion"
	CameraTag = "UIBlueprint_Promotion"
}