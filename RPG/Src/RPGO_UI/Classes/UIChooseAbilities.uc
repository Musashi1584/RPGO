class UIChooseAbilities extends UIInventory;

var array<X2AbilityTemplate> AbilitiesPool;
var array<Commodity>		CommodityPool;
var int						SelectedIndexPool;

var array<X2AbilityTemplate> AbilitiesChosen;
var array<Commodity>		CommoditiesChosen;
var int						SelectedIndexChosen;

var int ChooseAbilityMax;

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
var localized string m_strItemOwned;
var localized string m_strItemLimitReached;
var localized string m_strItemNotRemovable;

delegate AcceptAbilities(array<X2AbilityTemplate> SelectedAbiltites);

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	`LOG(self.Class.name @ GetFuncName() @ InitController @ InitMovie @ InitName @ InitMovie.UI_RES_X @ InitMovie.UI_RES_Y,, 'RPG-UIChooseSpecializations');

	super.InitScreen(InitController, InitMovie, InitName);

	BuildList(PoolList, PoolHeader, 'PoolList', 'PoolTitleHeader',
		120, m_strTitlePool, m_strInventoryLabelPool);

	BuildList(ChosenList, ChosenHeader, 'ChosenList', 'ChosenTitleHeader',
		1200, m_strTitleChosen, m_strInventoryLabelChosen);

	PoolList.BG.OnMouseEventDelegate = OnChildMouseEvent;
	ChosenList.BG.OnMouseEventDelegate = OnChildMouseEvent;

	PoolList.OnItemDoubleClicked = OnSpecializationsAdded;
	ChosenList.OnItemDoubleClicked = OnSpecializationsRemoved;
	
	AbilitiesPool.Length = 0;
	AbilitiesPool = GetAbilityTemplates(GetUnit());
	AbilitiesPool.Sort(SortAbiltiesByName);
	CommodityPool = ConvertToCommodities(AbilitiesPool);

	AbilitiesChosen.Length = 0;
	
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


simulated function array<X2AbilityTemplate> GetAbilityTemplates(XComGameState_Unit Unit, optional XComGameState CheckGameState)
{
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local array<X2AbilityTemplate> AbilityTemplates;
	local array<SoldierClassRandomAbilityDeck> RandomAbilityDecks;
	local SoldierClassRandomAbilityDeck Deck;
	local SoldierClassAbilityType AbilityType;
	
	if(Unit.IsSoldier())
	{
		AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

		RandomAbilityDecks = Unit.GetSoldierClassTemplate().RandomAbilityDecks;

		foreach RandomAbilityDecks(Deck)
		{
			foreach Deck.Abilities(AbilityType)
			{
				AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityType.AbilityName);
				if(AbilityTemplate != none &&
					!AbilityTemplate.bDontDisplayInAbilitySummary &&
					AbilityTemplate.ConditionsEverValidForUnit(Unit, true) )
				{
					AbilityTemplate.DefaultSourceItemSlot = AbilityType.ApplyToWeaponSlot;
					AbilityTemplates.AddItem(AbilityTemplate);
				}
			}
		}
	}
	return AbilityTemplates;
}

simulated function InitChooseAbiltites(StateObjectReference UnitRef ,int MaxAbilities, optional array<X2AbilityTemplate> OwnedAbiltites, optional delegate<AcceptAbilities> OnAccept)
{
	`LOG(self.Class.name @ GetFuncName() @ UnitRef.ObjectID,, 'RPG-UIChooseSpecializations');
	UnitReference = UnitRef;
	AbilitiesChosen = OwnedAbiltites;
	ChooseAbilityMax = MaxAbilities;
	AcceptAbilities = OnAccept;
	
	CommoditiesChosen = ConvertToCommodities(AbilitiesChosen);
	
	AbilitiesPool.Length = 0;
	AbilitiesPool = GetAbilityTemplates(GetUnit());
	AbilitiesPool.Sort(SortAbiltiesByName);
	CommodityPool = ConvertToCommodities(AbilitiesPool);

	PopulateData();
}

simulated function XComGameState_Unit GetUnit()
{
	return XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
}

simulated function OnContinueButtonClick()
{
	local UIArmory_PromotionHero HeroScreen;
	`log(default.class @ GetFuncName(),, 'RPG');
	
	if (AbilitiesChosen.Length == ChooseAbilityMax)
	{
		OnAllAbiltiesSelected();
		
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


function bool OnAllAbiltiesSelected()
{
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
	local X2AbilityTemplate Ability;
	
	UnitState = GetUnit();

	foreach AbilitiesChosen(Ability)
	{
		`log(default.class @ GetFuncName() @
			"Add Ability for" @ UnitState.SummaryString() @ 
			Ability.LocFriendlyName
		,, 'RPG');
	}

	NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding chosen starting abilities to unit");
	
	class'X2SecondWaveConfigOptions'.static.AddStartingAbilities(UnitState, AbilitiesChosen);
	
	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));
	UnitState.SetUnitFloatValue('SecondWaveCommandersChoiceAbilityChosen', 1, eCleanup_Never);
	
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	
	if (AcceptAbilities != none)
	{
		AcceptAbilities(AbilitiesChosen);
	}

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("StrategyUI_Recruit_Soldier");
	
	return true;
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

simulated function array<Commodity> ConvertToCommodities(array<X2AbilityTemplate> Abilities)
{
	local X2AbilityTemplate AbilityTemplate;
	local array<Commodity> Commodities;
	local Commodity Comm;

	foreach Abilities(AbilityTemplate)
	{
		Comm.Title = AbilityTemplate.LocFriendlyName;
		Comm.Desc = AbilityTemplate.GetMyHelpText();
		Comm.OrderHours = -1;
		
		Commodities.AddItem(Comm);
	}

	return Commodities;
}

function int SortAbiltiesByName(X2AbilityTemplate a, X2AbilityTemplate b)
{	
	if (a.LocFriendlyName < b.LocFriendlyName)
		return 1;
	else if (a.LocFriendlyName > b.LocFriendlyName)
		return -1;
	else
		return 0;
}
simulated function PopulateData()
{
	PopulatePool();
	PopulateChosen();
	UpdateButton();
}

simulated function PopulatePool()
{
	local Commodity Comm;
	local X2AbilityTemplate Template;
	local int i;
	local UIInventory_AbilityListItem Item;

	`LOG(self.Class.name @ GetFuncName(),, 'RPG-UIChooseSpecializations');

	PoolList.ClearItems();
	for(i = 0; i < CommodityPool.Length; i++)
	{
		Comm = CommodityPool[i];
		Template = AbilitiesPool[GetItemIndex(Comm)];
		Item = Spawn(class'UIInventory_AbilityListItem', PoolList.itemContainer);
		Item.InitInventoryListAbility(Template, Comm, ,m_strChoose, , , 90);
		UpdatePoolListItem(Item);
	}
}

simulated function UpdatePoolList()
{
	local int Index;

	for (Index = 0; Index < PoolList.GetItemCount(); Index++)
	{
		UpdatePoolListItem(UIInventory_AbilityListItem(PoolList.GetItem(Index)));
	}
}

simulated function UpdatePoolListItem(UIInventory_AbilityListItem Item)
{
	local int Index;

	Index = GetItemIndex(Item.ItemComodity);

	Item.EnableListItem();
	Item.ShouldShowGoodState(false);

	if (IsPicked(Index))
	{
		Item.ShouldShowGoodState(true, m_strItemChosen);
	}

	if (IsOwnedSpec(Index))
	{
		Item.SetDisabled(true, m_strItemOwned);
	}

	if (HasReachedSpecLimit())
	{
		Item.SetDisabled(true, m_strItemLimitReached);
	}
}

simulated function PopulateChosen()
{
	local Commodity Comm;
	local X2AbilityTemplate Template;
	local int i;
	local UIInventory_AbilityListItem Item;

	`LOG(self.Class.name @ GetFuncName(),, 'RPG-UIChooseSpecializations');

	ChosenList.ClearItems();
	for(i = 0; i < CommoditiesChosen.Length; i++)
	{
		Comm = CommoditiesChosen[i];
		Template = AbilitiesChosen[i];
		Item = Spawn(class'UIInventory_AbilityListItem', ChosenList.itemContainer);
		Item.InitInventoryListAbility(Template, Comm, , m_strRemove, , , 90);
		UpdateChosenListItem(Item);
	}
}

simulated function UpdateChosenList()
{
	local int Index;

	for (Index = 0; Index < ChosenList.GetItemCount(); Index++)
	{
		UpdateChosenListItem(UIInventory_AbilityListItem(ChosenList.GetItem(Index)));
	}
}

simulated function UpdateChosenListItem(UIInventory_AbilityListItem Item)
{
	Item.EnableListItem();

	if (IsOwnedSpec(GetItemIndex(Item.ItemComodity)))
		Item.SetDisabled(true, m_strItemNotRemovable);
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
	return false;
}

simulated function bool HasReachedSpecLimit()
{;
	return CommoditiesChosen.Length >= ChooseAbilityMax;
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

	PoolIndex = GetItemIndex(UIInventory_AbilityListItem(ChosenList.GetItem(SelectedIndexChosen)).ItemComodity);

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
	AbilitiesChosen.AddItem(AbilitiesPool[Index]);
	CommoditiesChosen = ConvertToCommodities(AbilitiesChosen);
}

simulated function RemoveFromChosenList(int ChosenIndex, int PoolIndex)
{
	AbilitiesChosen.RemoveItem(AbilitiesChosen[ChosenIndex]);
	CommoditiesChosen = ConvertToCommodities(AbilitiesChosen);
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
		return false;

	if(cmd == class'UIUtilities_Input'.const.FXS_BUTTON_X)
	{
		OnContinueButtonClick();
		return true;
	}
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
	NavHelp.AddContinueButton(OnContinueButtonClick);

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

defaultproperties
{
	bAutoSelectFirstNavigable = false
	bHideOnLoseFocus = true
	
	InputState = eInputState_Consume
	
	DisplayTag = "UIBlueprint_Promotion"
	CameraTag = "UIBlueprint_Promotion"
}