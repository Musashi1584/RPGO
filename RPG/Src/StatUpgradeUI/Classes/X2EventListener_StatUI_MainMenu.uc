class X2EventListener_StatUI_MainMenu extends X2EventListener;

var delegate<OnItemSelectedCallback> NextOnSelectionChanged;
delegate OnItemSelectedCallback(UIList _list, int itemIndex);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateMainMenuListenerTemplate());

	return Templates;
}

static function CHEventListenerTemplate CreateMainMenuListenerTemplate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'StealthOverhaulOnTacticalBeginPlay');

	Template.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('OnArmoryMainMenuUpdate', OnArmoryMainMenuUpdate, ELD_Immediate);
	`LOG("Register Event OnArmoryMainMenuUpdate",, 'RPG');

	return Template;
}


static function EventListenerReturn OnArmoryMainMenuUpdate(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local UIList List;
	local UIArmory_MainMenu MainMenu;
	local UIListItemString StatUIButton;

	`LOG(GetFuncName(),, 'RPG');
	
	List = UIList(EventData);
	MainMenu = UIArmory_MainMenu(EventSource);

	StatUIButton = MainMenu.Spawn(class'UIListItemString', List.ItemContainer).InitListItem(class'UIBarMemorial_Details'.default.m_strSoldierStats);
	StatUIButton.MCName = 'ArmoryMainMenu_StatUIButton';
	StatUIButton.ButtonBG.OnClickedDelegate = OnSoldierStats;

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

simulated static function UIListItemString FindDismissListItem(UIList List)
{

	return UIListItemString(List.GetChildByName('ArmoryMainMenu_DismissButton', false));
}
