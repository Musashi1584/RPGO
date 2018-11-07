class X2EventListener_StatUI extends X2EventListener config(UI);

var config int StatPointsPerPromotion;

var delegate<OnItemSelectedCallback> NextOnSelectionChanged;
delegate OnItemSelectedCallback(UIList _list, int itemIndex);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateMainMenuListenerTemplate());
	Templates.AddItem(CreateListenerTemplate_OnUnitRankUp());

	return Templates;
}

static function CHEventListenerTemplate CreateMainMenuListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'StatsUIOnArmoryMainMenuUpdate');

	Template.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('OnArmoryMainMenuUpdate', OnArmoryMainMenuUpdate, ELD_Immediate);
	`LOG("Register Event OnArmoryMainMenuUpdate",, 'RPG');

	return Template;
}

static function CHEventListenerTemplate CreateListenerTemplate_OnUnitRankUp()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RPGUnitRankUp');

	Template.RegisterInTactical = true;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('UnitRankUp', OnUnitRankUp, ELD_Immediate);
	`LOG("Register Event OnUnitRankUp",, 'RPG');

	return Template;
}

static function EventListenerReturn OnUnitRankUp(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit UnitState;
	local UnitValue StatPointsValue;

	UnitState = XComGameState_Unit(EventData);

	if (UnitState != none)
	{
		UnitState = XComGameState_Unit(GameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));	
		UnitState.GetUnitValue('StatPoints', StatPointsValue);
		UnitState.SetUnitFloatValue('StatPoints', StatPointsValue.fValue + default.StatPointsPerPromotion, eCleanup_Never);
		GameState.AddStateObject(UnitState);
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnArmoryMainMenuUpdate(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local UIList List;
	local UIArmory_MainMenu MainMenu;
	local UIListItemString StatUIButton;
	local XComGameState_Unit UnitState;
	local UnitValue StatPointsValue;

	`LOG(GetFuncName(),, 'RPG');
	
	List = UIList(EventData);
	MainMenu = UIArmory_MainMenu(EventSource);	
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(MainMenu.GetUnitRef().ObjectID));
	UnitState.GetUnitValue('StatPoints', StatPointsValue);

	StatUIButton = MainMenu.Spawn(class'UIListItemString', List.ItemContainer).InitListItem(class'UIBarMemorial_Details'.default.m_strSoldierStats);
	StatUIButton.MCName = 'ArmoryMainMenu_StatUIButton';
	StatUIButton.ButtonBG.OnClickedDelegate = OnSoldierStats;
	StatUIButton.NeedsAttention(StatPointsValue.fValue > 0);

	//if(NextOnSelectionChanged == none)
	//{
	// 	NextOnSelectionChanged = List.OnSelectionChanged;
	//	List.OnSelectionChanged = OnSelectionChanged;
	//}
	List.MoveItemToBottom(FindDismissListItem(List));

	return ELR_NoInterrupt;
}


simulated function OnSoldierStats(UIButton kButton)
{
	local UIArmory_MainMenu MainMenu;
	local XComHQPresentationLayer HQPres;
	local UIScreen_StatUI StatScreen;

	MainMenu = UIArmory_MainMenu(kButton.GetParent(class'UIArmory_MainMenu', true));

	HQPres = XComHQPresentationLayer(MainMenu.Movie.Pres);

	if( HQPres == none )
		return;

	if (`SCREENSTACK.IsNotInStack(class'UIScreen_StatUI'))
	{
		//StatScreen = UIScreen_StatUI(HQPres.ScreenStack.Push(HQPres.Spawn(class'UIScreen_StatUI', HQPres), HQPres.Get3DMovie()));
		StatScreen = UIScreen_StatUI(HQPres.ScreenStack.Push(HQPres.Spawn(class'UIScreen_StatUI', HQPres)));
		StatScreen.InitArmory(MainMenu.GetUnitRef());
	}

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("Play_MenuSelect");
}

simulated static function UIListItemString FindDismissListItem(UIList List)
{
	return UIListItemString(List.GetChildByName('ArmoryMainMenu_DismissButton', false));
}


simulated function OnSelectionChanged(UIList ContainerList, int ItemIndex)
{
	local UIArmory_MainMenu MainMenu;

	MainMenu = UIArmory_MainMenu(ContainerList.GetParent(class'UIArmory_MainMenu', true));

	if (ContainerList.GetItem(ItemIndex).MCName == 'ArmoryMainMenu_StatUIButton') 
	{
		MainMenu.MC.ChildSetString("descriptionText", "htmlText", class'UIUtilities_Text'.static.AddFontInfo("DESCRIPTION TODO", true));
		return;
	}
	NextOnSelectionChanged(ContainerList, ItemIndex);
}
