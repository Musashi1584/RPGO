class UIChooseSpecializations extends UIInventory dependson(X2EventListener_RPG_StrategyListener);

var array<SoldierSpecialization> SpecializationsPool;
var array<Commodity>		CommodityPool;
var int						SelectedIndexPool;

var array<SoldierSpecialization> SpecializationsChosen;
var array<Commodity>		CommoditiesChosen;
var int						SelectedIndexChosen;

var int ChooseSpecializationMax;
var array<int> SelectedItems, OwnedItems;

var UIX2PanelHeader PoolHeader;
var UIList PoolList;
var UIX2PanelHeader ChosenHeader;
var UIList ChosenList;
var UIButton SaveButton;

// var StateObjectReference m_UnitRef;


var localized string m_strTitlePool;
var localized string m_strInventoryLabelPool;
var localized string m_strTitleChosen;
var localized string m_strInventoryLabelChosen;
var localized string m_strChoose;
var localized string m_strRemove;

delegate OnClickedDelegate(UIButton Button);

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	`LOG(self.Class.name @ GetFuncName() @ InitController @ InitMovie @ InitName @ Movie.UI_RES_X @ Movie.UI_RES_Y,, 'RPG-UIChooseSpecializations');

	super.InitScreen(InitController, InitMovie, InitName);

	SaveButton = Spawn(class'UIButton', self).InitButton('SaveButton', "ACCEPT");
	SaveButton.SetFontSize(26);
	SaveButton.SetResizeToText(true);
	SaveButton.SetWidth(150);
	SaveButton.SetPosition(Movie.UI_RES_X / 2 - SaveButton.Width / 2, Movie.UI_RES_Y - SaveButton.Height - 50);
	SaveButton.Show();
	SaveButton.DisableButton();

	BuildList(PoolList, PoolHeader, 'PoolList', 'PoolTitleHeader',
		120, m_strTitlePool, m_strInventoryLabelPool);

	BuildList(ChosenList, ChosenHeader, 'ChosenList', 'ChosenTitleHeader',
		1200, m_strTitleChosen, m_strInventoryLabelChosen);

	PoolList.BG.OnMouseEventDelegate = OnChildMouseEvent;
	ChosenList.BG.OnMouseEventDelegate = OnChildMouseEvent;

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
	PoolList.SetSelectedIndex(0);

	//if( bIsIn3D )
	//	class'UIUtilities'.static.DisplayUI3D(DisplayTag, CameraTag, OverrideInterpTime != -1 ? OverrideInterpTime : `HQINTERPTIME);
}

simulated function InitChooseSpecialization(int MaxSpecs, array<SoldierSpecialization> OwnedSpecs, delegate<OnClickedDelegate> OnAccept)
{
	local Commodity Comm;

	`LOG(self.Class.name @ GetFuncName() @ OwnedSpecs.Length @ MaxSpecs,, 'RPG-UIChooseSpecializations');
	SpecializationsChosen = OwnedSpecs;
	ChooseSpecializationMax = MaxSpecs;
	SaveButton.OnClickedDelegate = OnAccept;
	
	CommoditiesChosen = ConvertToCommodities(SpecializationsChosen);

	foreach CommoditiesChosen(Comm)
	{
		OwnedItems.AddItem(GetItemIndex(Comm));
	}

	PopulateData();
}

simulated function BuildList(out UIList CommList, out UIX2PanelHeader Header, name ListName, name HeaderName,
	int PositionX, optional string HeaderTitle = "", optional string HeaderSubtitle = "")
{
	CommList = Spawn(class'UIList', self);
	CommList.BGPaddingTop = 90;
	CommList.BGPaddingRight = 30;
	CommList.bSelectFirstAvailable = false;
	CommList.bAnimateOnInit = false;
	CommList.InitList(ListName,
		PositionX, 230,
		568, 710,
		false, true
	);
	CommList.BG.SetAlpha(75);
	CommList.Show();
 
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
		//Comm.OrderHours = class'SpecialTrainingUtilities'.static.GetSpecialTrainingDays() * 24;

		Commodities.AddItem(Comm);
	}

	return Commodities;
}
/*
function int SortSpecializationsByName(SoldierSpecialization a, SoldierSpecialization b)
{	
	if (a.DisplayName < b.DisplayName)
		return 1;
	else if (a.DisplayName > b.DisplayName)
		return -1;
	else
		return 0;
}
*/
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
	local UIInventory_ClassListItem Item;

	`LOG(self.Class.name @ GetFuncName(),, 'RPG-UIChooseSpecializations');

	PoolList.ClearItems();
	for(i = 0; i < CommodityPool.Length; i++)
	{
		Template = CommodityPool[i];
		Item = Spawn(class'UIInventory_ClassListItem', PoolList.itemContainer);
		Item.InitInventoryListCommodity(Template, , m_strChoose, , , 126);
		UpdatePoolListItem(Item);
	}
}

simulated function UpdatePoolList()
{
	local int Index;

	for (Index = 0; Index < PoolList.GetItemCount(); Index++)
	{
		UpdatePoolListItem(UIInventory_ClassListItem(PoolList.GetItem(Index)));
	}
}

simulated function UpdatePoolListItem(UIInventory_ClassListItem Item)
{
	local int Index;

	Index = GetItemIndex(Item.ItemComodity);

	Item.EnableListItem();
	Item.ShouldShowGoodState(false);

	if (IsPicked(Index))
	{
		Item.ShouldShowGoodState(true, "You already have a chosen this specialization.");
		Item.SetDisabled(true);
	}

	if (IsOwnedSpec(Index))
	{
		Item.SetDisabled(true, "Random specialization.");
	}

	if (HasReachedSpecLimit())
	{
		Item.SetDisabled(true, "You cannot pick any more specialization.");
	}
}

simulated function PopulateChosen()
{
	local Commodity Template;
	local int i;
	local UIInventory_ClassListItem Item;

	`LOG(self.Class.name @ GetFuncName(),, 'RPG-UIChooseSpecializations');

	ChosenList.ClearItems();
	for(i = 0; i < CommoditiesChosen.Length; i++)
	{
		Template = CommoditiesChosen[i];
		Item = Spawn(class'UIInventory_ClassListItem', ChosenList.ItemContainer);
		Item.InitInventoryListCommodity(Template, , m_strRemove, , , 126);
		UpdateChosenListItem(Item);
	}
}

simulated function UpdateChosenList()
{
	local int Index;

	for (Index = 0; Index < ChosenList.GetItemCount(); Index++)
	{
		UpdateChosenListItem(UIInventory_ClassListItem(ChosenList.GetItem(Index)));
	}
}

simulated function UpdateChosenListItem(UIInventory_ClassListItem Item)
{
	Item.EnableListItem();

	if (IsOwnedSpec(GetItemIndex(Item.ItemComodity)))
		Item.SetDisabled(true, "Random specializations cant be removed.");
}

simulated function UpdateButton()
{
	if (HasReachedSpecLimit())
	{
		SaveButton.EnableButton();
	}
	else
	{
		SaveButton.DisableButton();
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
	if (itemIndex != SelectedIndexPool)
	{
		SelectedIndexPool = itemIndex;
	}

	if (!IsPicked(SelectedIndexPool))
	{
		AddToChosenList(SelectedIndexPool);
		UpdateAll();
	}
	else
	{
		PlayNegativeSound();
	}
}

simulated function OnSpecializationsRemoved(UIList kList, int itemIndex)
{
	local int PoolIndex;
	
	if (itemIndex != SelectedIndexChosen)
	{
		SelectedIndexChosen = itemIndex;
	}

	PoolIndex = GetItemIndex(UIInventory_ClassListItem(ChosenList.GetItem(SelectedIndexChosen)).ItemComodity);

	if (!IsOwnedSpec(PoolIndex))
	{
		RemoveFromChosenList(SelectedIndexChosen, PoolIndex);
		UpdateAll();
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

	bHandled = super.OnUnrealCommand(cmd, arg);

	if (bHandled)
	{
		if (PoolList.GetSelectedItem() != none)
			SelectedIndexPool = PoolList.GetItemIndex(PoolList.GetSelectedItem());
	}
	/* TODO: Fix controller support
	else
	{
		if (`ISCONTROLLERACTIVE && CanTrainSpecialization(SelectedIndexPool))
		{
			switch (cmd)
			{
			case class'UIUtilities_Input'.const.FXS_BUTTON_A :
				OnSpecializationsAdded(PoolList, SelectedIndexPool);
				bHandled = true;
				break;
			}
		}
	}
	*/
	return bHandled;
}

simulated function UpdateNavHelp()
{
	local UINavigationHelp NavHelp;

	NavHelp = `HQPRES.m_kAvengerHUD.NavHelp;

	NavHelp.ClearButtonHelp();
	NavHelp.bIsVerticalHelp = `ISCONTROLLERACTIVE;
	NavHelp.AddBackButton(OnCancel);

	if(`ISCONTROLLERACTIVE && !IsPicked(SelectedIndexPool))
	{
		NavHelp.AddSelectNavHelp();
	}
}

simulated function PlayNegativeSound()
{
	if(!`ISCONTROLLERACTIVE)
		class'UIUtilities_Sound'.static.PlayNegativeSound();
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

simulated function OnChildMouseEvent(UIPanel Control, int Cmd)
{
	switch(Cmd)
	{
		case class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT:
			PoolList.ClearSelection();
			ChosenList.ClearSelection();
			break;
	}
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
	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();
	`HQPRES.m_kAvengerHUD.NavHelp.AddBackButton(OnCancel);
}

//simulated function BuildScreen()
//{
//	`LOG(self.Class.name @ GetFuncName() @ InventoryListName,, 'RPG-UIChooseSpecializations');
//
//	//ListContainer = Spawn(class'UIPanel', self).InitPanel('InventoryContainer');
//	//ListContainer.Width = Movie.UI_RES_X - 100;
//	//ListContainer.Height = Movie.UI_RES_Y - 100;
//	//ListContainer.SetPosition((Movie.UI_RES_X - ListContainer.Width) / 2, (Movie.UI_RES_Y- ListContainer.Height) / 2);
//	
//	//ListBG = Spawn(class'UIPanel', ListContainer);
//	//ListBG.InitPanel('InventoryListBG'); 
//	//ListBG.bShouldPlayGenericUIAudioEvents = false;
//	//ListBG.Show();
//
//
//}

defaultproperties
{
	bAutoSelectFirstNavigable = false
	bHideOnLoseFocus = true
	
	InputState = eInputState_Consume
	
	DisplayTag="UIBlueprint_ArmoryMenu"
	CameraTag="UIBlueprint_ArmoryMenu"

}