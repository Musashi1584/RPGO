class UIChooseClass_SWO_CommandersChoice extends UIChooseClass dependson(X2EventListener_RPG_StrategyListener);

var XcomGameState_Unit Unit;
var array<SoldierSpecialization> Specializations;
var int SpecNumber;
var array<int> DisabledItems;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	super.InitScreen(InitController, InitMovie, InitName);

	ItemCard.Hide();
}

simulated function InitChooseSpec(XcomGameState_Unit UnitState, int SpecNumberToSet, array<int> DisabledItemsToSet)
{
	Unit = UnitState;
	SpecNumber = SpecNumberToSet;
	DisabledItems = DisabledItemsToSet;

	//SetCategory(m_strInventoryLabel);
	//TitleHeader.InitPanelHeader('TitleHeader', m_strTitle @ SpecNumber + 1, m_strSubTitleTitle);
	//TitleHeader.SetHeaderWidth(580);
}

simulated function PopulateData()
{
	local UIInventory_ClassListItem Item;
	local Commodity Template;
	local int i;

	List.ClearItems();
	List.bSelectFirstAvailable = false;
	
	for(i = 0; i < arrItems.Length; i++)
	{
		Template = arrItems[i];
		if(i < m_arrRefs.Length)
		{
			Item = Spawn(class'UIInventory_ClassListItem', List.itemContainer);
			Item.InitInventoryListCommodity(Template, m_arrRefs[i], GetButtonString(i), m_eStyle, , 126);
		}
		else
		{
			Item = Spawn(class'UIInventory_ClassListItem', List.itemContainer);
			Item.InitInventoryListCommodity(Template, , GetButtonString(i), m_eStyle, , 126);
		}
		if (DisabledItems.Find(i) != INDEX_NONE)
		{
			`LOG(self.Class.name @ GetFuncName() @ "Disable" @ Template.Title,, 'RPG-PromotionScreen');
			Item.SetDisabled(true, "Specialization already chosen");
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

simulated function bool IsItemPurchased(int ItemIndex)
{
	return DisabledItems.Find(ItemIndex) != INDEX_NONE;
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