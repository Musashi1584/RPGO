class UIChooseClass_SWO_CommandersChoice extends UIChooseClass dependson(X2EventListener_RPG_StrategyListener);

//var UIArmory_MainMenu ParentScreen;
var XcomGameState_Unit Unit;
var array<SoldierSpecialization> Specializations;

//-------------- EVENT HANDLING --------------------------------------------------------
simulated function OnPurchaseClicked(UIList kList, int itemIndex)
{
	if (itemIndex != iSelectedItem)
	{
		iSelectedItem = itemIndex;
	}

	else
	{
		OnSpecSelected(iSelectedItem);
		Movie.Stack.Pop(self);
		//UpdateData();
	}

}

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	ItemCard.Hide();

	Movie.Stack.MoveToTopOfStack(self.Class);
}

simulated function PopulateData()
{
	local Commodity Template;
	local int i;

	List.ClearItems();
	List.bSelectFirstAvailable = false;
	
	for(i = 0; i < arrItems.Length; i++)
	{
		Template = arrItems[i];
		if(i < m_arrRefs.Length)
		{
			Spawn(class'UIInventory_ClassListItem', List.itemContainer).InitInventoryListCommodity(Template, m_arrRefs[i], GetButtonString(i), m_eStyle, , 126);
		}
		else
		{
			Spawn(class'UIInventory_ClassListItem', List.itemContainer).InitInventoryListCommodity(Template, , GetButtonString(i), m_eStyle, , 126);
		}
	}
}

simulated function PopulateResearchCard(optional Commodity ItemCommodity, optional StateObjectReference ItemRef)
{
}

//-------------- GAME DATA HOOKUP --------------------------------------------------------
simulated function GetItems()
{
	arrItems = ConvertSpecializationsToCommodities();
}

simulated function array<Commodity> ConvertSpecializationsToCommodities()
{
	local SoldierSpecialization Spec;
	local X2UniversalSoldierClassInfo UniversalSoldierClassTemplate;
	local int Index;
	local array<Commodity> arrCommodoties;
	local Commodity ClassComm;
	
	Specializations.Length = 0;
	Specializations = class'X2TemplateHelper_RPGOverhaul'.static.GetSpecializations();
	
	for (Index = 0; Index < Specializations.Length; Index++)
	{
		Spec = Specializations[Index];
		
		UniversalSoldierClassTemplate = new(None, string(Spec.TemplateName))class'X2UniversalSoldierClassInfo';

		ClassComm.Title = UniversalSoldierClassTemplate.ClassSpecializationTitle;
		ClassComm.Image = UniversalSoldierClassTemplate.ClassSpecializationIcon;
		ClassComm.Desc = UniversalSoldierClassTemplate.ClassSpecializationSummary;
		//ClassComm.OrderHours = XComHQ.GetTrainRookieDays() * 24;

		arrCommodoties.AddItem(ClassComm);
	}

	return arrCommodoties;
}

//-----------------------------------------------------------------------------

//This is overwritten in the research archives. 

function bool OnSpecSelected(int iOption)
{
	local XComGameState NewGameState;
	local name NewSpec;

	NewSpec = Specializations[iOption].TemplateName;

	`log(default.class @ GetFuncName() @ "Chosen NewSpec is:" @ NewSpec,, 'RPG');

	//if(Unit.GetSoldierClassTemplate().DataName==NewClass) //if trying to change into class the unit already is return
	//	return false;

	NewGameState=class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Ranking up Unit in chosen Class");

	//Unit.MakeItemsAvailable(NewGameState, False);
	//Unit.RankUpSoldier(NewGameState, NewClass);
	//Unit.ApplySquaddieLoadout(NewGameState);

	`XSTRATEGYSOUNDMGR.PlaySoundEvent("StrategyUI_Recruit_Soldier");
	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
	`HQPRES.UIArmory_Promotion(Unit.GetReference());
	//ParentScreen.PopulateData();

	return true;
}

//----------------------------------------------------------------
simulated function OnCancelButton(UIButton kButton) { OnCancel(); }
simulated function OnCancel()
{
	CloseScreen();
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
	InputState = eInputState_Consume;

	bHideOnLoseFocus = true;
	bConsumeMouseEvents = true;

	DisplayTag="UIBlueprint_Promotion"
	CameraTag="UIBlueprint_Promotion"
}