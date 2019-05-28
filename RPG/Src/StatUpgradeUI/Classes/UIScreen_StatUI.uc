class UIScreen_StatUI extends UIArmory config(StatUpgradeUI);

var UIPanel Container;
var UIBGBox PanelBG;
var UIBGBox FullBG;
var UIX2PanelHeader TitleHeader;
var UIImage SCImage;
var UIButton SaveButton;
var UIText NaturalAptitudeText, StatPointsText, AbilityPointsText, StatNameHeader, StatValueHeader, UpgradePointsHeader, StatCostHeader, UpgradeCostHeader;
var array<UIPanel_StatUI_StatLine> StatLines;
var bool bLog;

var XComGameState_Unit UnitState;
var int StatPointCostSum, AbilityPointCostSum, FontSize, Padding, LeftPadding, StatOffsetY;

var localized string m_strSoldierSPLabel, m_StatNameHeader, m_StatValueHeader, m_UpgradePointsHeader, m_StatCostHeader, m_UpgradeCostHeader;

simulated function InitArmory(StateObjectReference UnitRef, optional name DispEvent, optional name SoldSpawnEvent, optional name NavBackEvent, optional name HideEvent, optional name RemoveEvent, optional bool bInstant = false, optional XComGameState InitCheckGameState)
{
	super.InitArmory(UnitRef, DispEvent, SoldSpawnEvent, NavBackEvent, HideEvent, RemoveEvent, bInstant, InitCheckGameState);
	bAutoSelectFirstNavigable = `ISCONTROLLERACTIVE;
	InitPanels();

	`LOG(self.class.name @ GetFuncName() @ UnitState.GetFullName(), bLog, 'RPG');
}

function InitPanels()
{
	local int RunningHeaderOffsetX;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));

	Container = Spawn(class'UIPanel', self).InitPanel('theContainer');
	Container.Width = Width;
	Container.Height = Height;
	Container.SetPosition((Movie.UI_RES_X - Container.Width) / 2, (Movie.UI_RES_Y- Container.Height) / 2);
	Container.Navigator.LoopSelection = true;
	if(!bAutoSelectFirstNavigable)
	{
		Container.SetSelectedNavigation();
	}

	FullBG = Spawn(class'UIBGBox', Container);
	FullBG.InitBG('', 0, 0, Container.Width, Container.Height);

	PanelBG = Spawn(class'UIBGBox', Container);
	PanelBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	PanelBG.InitBG('theBG', 0, 0, Container.Width, Container.Height);

	RunningHeaderOffsetX = LeftPadding;

	SCImage = Spawn(class'UIImage', Container).InitImage();
	SCImage.SetSize(80, 80);
	SCImage.SetPosition(RunningHeaderOffsetX, RunningHeaderOffsetX);

	StatPointsText = Spawn(class'UIText', Container).InitText('StatPointsText');
	StatPointsText.SetWidth(200);
	StatPointsText.SetPosition(Container.Width - StatPointsText.Width - LeftPadding, LeftPadding);

	AbilityPointsText = Spawn(class'UIText', Container).InitText('AbilityPointsText');
	AbilityPointsText.SetWidth(200);
	AbilityPointsText.SetPosition(Container.Width - AbilityPointsText.Width - StatPointsText.Width - LeftPadding, LeftPadding);

	NaturalAptitudeText = Spawn(class'UIText', Container).InitText('NaturalAptitudeText');
	NaturalAptitudeText.SetWidth(450);
	NaturalAptitudeText.SetPosition(Container.Width - NaturalAptitudeText.Width - LeftPadding, LeftPadding * 2);

	TitleHeader = Spawn(class'UIX2PanelHeader', Container);
	TitleHeader.bIsNavigable = false; // Why doesn't UIX2PanelHeader have navigation disabled by default like UITest and UIImage eh, Firaxis?
	TitleHeader.InitPanelHeader('', "", "");
	TitleHeader.SetPosition(SCImage.Width + RunningHeaderOffsetX + 10, LeftPadding);
	TitleHeader.SetWidth(Container.Width - AbilityPointsText.Width - (LeftPadding * 2) - RunningHeaderOffsetX);
	TitleHeader.SetHeaderWidth(Container.Width - AbilityPointsText.Width - (LeftPadding * 2) - RunningHeaderOffsetX);

	SaveButton = Spawn(class'UIButton', Container);
	SaveButton.bIsNavigable = false;
	SaveButton.InitButton('SaveButton', "SAVE", Save, eUIButtonStyle_HOTLINK_BUTTON);
	SaveBUtton.SetGamepadIcon(class'UIUtilities_Input'.const.ICON_X_SQUARE);
	SaveButton.SetFontSize(FontSize);
	SaveButton.SetResizeToText(true);
	SaveButton.SetWidth(150);
	SaveButton.SetPosition(Width / 2 - SaveButton.Width / 2, Height - SaveButton.Height - 30);

	InitStatHeaders(250, 60, 80, 100, 120);
	InitStatLines();

	PopulateHeaderData();
	PopulateSoldierPoints();
}

function InitStatHeaders(
	int StatNameHeaderWidth,
	int StatValueHeaderWidth,
	int UpgradePointsHeaderWidth,
	int StatCostHeaderWidth,
	int UpgradeCostHeaderWidth)
{
	local int RunningOffsetX, OffsetY;

	RunningOffsetX = LeftPadding;
	OffsetY = StatOffsetY + 50;

	StatNameHeader = Spawn(class'UIText', Container).InitText('StatNameHeader');
	StatNameHeader.SetWidth(StatNameHeaderWidth);
	StatNameHeader.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(m_StatNameHeader, eUIState_Header));

	StatValueHeader = Spawn(class'UIText', Container).InitText('StatValueHeader');
	StatValueHeader.SetWidth(StatValueHeaderWidth);
	StatValueHeader.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(m_StatValueHeader, eUIState_Header));

	UpgradePointsHeader = Spawn(class'UIText', Container).InitText('UpgradePointsHeader');
	UpgradePointsHeader.SetWidth(UpgradePointsHeaderWidth);
	UpgradePointsHeader.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(m_UpgradePointsHeader, eUIState_Header));

	StatCostHeader = Spawn(class'UIText', Container).InitText('StatCostHeader');
	StatCostHeader.SetWidth(StatCostHeaderWidth);
	StatCostHeader.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(m_StatCostHeader, eUIState_Header));

	UpgradeCostHeader = Spawn(class'UIText', Container).InitText('UpgradeCostHeader');
	UpgradeCostHeader.SetWidth(UpgradeCostHeaderWidth);
	UpgradeCostHeader.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(m_UpgradeCostHeader, eUIState_Header));
	
	StatNameHeader.SetPosition(RunningOffsetX, OffsetY);
	StatValueHeader.SetPosition(RunningOffsetX += StatNameHeader.Width + Padding, OffsetY);
	UpgradePointsHeader.SetPosition(RunningOffsetX += StatValueHeader.Width + Padding, OffsetY);
	StatCostHeader.SetPosition(RunningOffsetX += 350 + UpgradePointsHeader.Width + Padding, OffsetY);
	UpgradeCostHeader.SetPosition(RunningOffsetX += UpgradeCostHeader.Width + Padding, OffsetY);
}

function InitStatLines()
{
	local UIPanel_StatUI_StatLine StatLine;
	local int Index, OffsetX, OffsetY;
	local bool bUseBetaStrikeHealthProgression;

	bUseBetaStrikeHealthProgression = UnitState.GetSoldierClassTemplateName() == 'UniversalSoldier';

	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_HP, int(UnitState.GetMaxStat(eStat_HP)), OnClickedIncrease, OnClickedDecrease, bUseBetaStrikeHealthProgression);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Mobility, int(UnitState.GetMaxStat(eStat_Mobility)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Offense, int(UnitState.GetMaxStat(eStat_Offense)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Will, int(UnitState.GetMaxStat(eStat_Will)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	//StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_ArmorMitigation, int(UnitState.GetMaxStat(eStat_ArmorMitigation)), OnClickedIncrease, OnClickedDecrease);
	//StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Dodge, int(UnitState.GetMaxStat(eStat_Dodge)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Defense, int(UnitState.GetMaxStat(eStat_Defense)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Hacking, int(UnitState.GetMaxStat(eStat_Hacking)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_PsiOffense, int(UnitState.GetMaxStat(eStat_PsiOffense)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);

	Index = 0;
	foreach StatLines(StatLine)
	{
		OffsetX = 40;
		OffsetY = 30;
		StatLine.SetPosition(OffsetX, StatOffsetY + (OffsetY * Index));
		`LOG(self.class.name @ GetFuncName() @ StatLine.MCName @ FontSize, bLog, 'RPG');
		Index++;
	}
}


function PopulateHeaderData()
{
	local string NaturalAptitude;

	if (UnitState.GetSoldierClassTemplate() != none)
	{
		SCImage.LoadImage(UnitState.GetSoldierClassIcon());
		SCImage.Show();
	}

	TitleHeader.SetText(UnitState.GetName(eNameType_FullNick), Caps(UnitState.IsSoldier() ? UnitState.GetSoldierClassDisplayName() : ""));
	TitleHeader.MC.FunctionVoid("realize");

	NaturalAptitude = class'UIUtilities_Text'.static.AlignRight(class'UIUtilities_Text'.static.GetColoredText(class'StatUIHelper'.default.NaturalAptitude $ ":" @ Caps(class'StatUIHelper'.static.GetNaturalAptitudeLabel(class'StatUIHelper'.static.GetNaturalAptitude(UnitState))), eUIState_Normal, FontSize));
	NaturalAptitudeText.SetHtmlText(NaturalAptitude);
}

function PopulateSoldierPoints()
{
	local int CurrentAP, CurrentSP;

	CurrentSP = Max(GetSoldierSP() - StatPointCostSum, 0);
	CurrentAP = GetSoldierAP() - AbilityPointCostSum - Min(GetSoldierSP() - StatPointCostSum, 0);

	StatPointsText.SetHtmlText(class'UIUtilities_Text'.static.AlignRight(class'UIUtilities_Text'.static.GetColoredText(m_strSoldierSPLabel $ ": " $ string(CurrentSP), eUIState_Normal, FontSize)));
	AbilityPointsText.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(class'UIArmory_PromotionHero'.default.m_strSoldierAPLabel $ ": " $ string(CurrentAP), eUIState_Normal, FontSize));
}

function int GetSoldierAP()
{
	return UnitState.AbilityPoints;
}

function int GetSoldierSP()
{
	local UnitValue StatPointsValue;
	UnitState.GetUnitValue('StatPoints', StatPointsValue);
	return int(StatPointsValue.fValue);
}

function int GetSpentSoldierSP()
{
	local UnitValue StatPointsValue;
	UnitState.GetUnitValue('SpentStatPoints', StatPointsValue);
	return int(StatPointsValue.fValue);
}

function Save(UIButton Button)
{
	`LOG(self.Class.name @ GetFuncName(), bLog, 'RPG');
	OnAccept();
}

simulated function OnCancel()
{
	super.OnCancel();
}

simulated function OnAccept()
{
	if (AbilityPointCostSum + StatPointCostSum > 0)
		ConfirmStatUpgrade();
	else
		Movie.Pres.PlayUISound(eSUISound_MenuClickNegative);
}

simulated function ConfirmStatUpgrade()
{
	local TDialogueBoxData DialogData;

	DialogData.eType = eDialog_Alert;
	DialogData.bMuteAcceptSound = true;
	DialogData.strTitle = class'UIArmory_WeaponUpgrade'.default.m_strConfirmDialogTitle;
	DialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericYes;
	DialogData.strCancel = class'UIUtilities_Text'.default.m_strGenericNO;
	DialogData.fnCallback = ComfirmStatUpgradeCallback;

	Movie.Pres.UIRaiseDialog(DialogData);
}

simulated function ComfirmStatUpgradeCallback(Name Action)
{
	local XComGameStateHistory History;
	local XComGameState UpdateState;
	local XComGameStateContext_ChangeContainer ChangeContainer;
	local XComGameState_Unit UpdatedUnit;
	local UIPanel_StatUI_StatLine StatLine;

	if (Action == 'eUIAction_Accept')
	{
		History = `XCOMHISTORY;
		ChangeContainer = class'XComGameStateContext_ChangeContainer'.static.CreateEmptyChangeContainer("Upgrade Stats in StatUI");
		UpdateState = History.CreateNewGameState(true, ChangeContainer);

		UpdatedUnit = XComGameState_Unit(UpdateState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));

		foreach StatLines(StatLine)
		{
			if (StatLine.StatValue > int(UnitState.GetMaxStat(StatLine.StatType)))
			{
				UpdatedUnit.SetBaseMaxStat(StatLine.StatType, float(StatLine.StatValue), ECSMAR_Additive);
			}
		}

		UpdatedUnit.AbilityPoints -= AbilityPointCostSum;
		UpdatedUnit.SpentAbilityPoints += AbilityPointCostSum;
		UpdatedUnit.SetUnitFloatValue('StatPoints', float(GetSoldierSP() - StatPointCostSum), eCleanup_Never);
		UpdatedUnit.SetUnitFloatValue('SpentStatPoints', float(GetSpentSoldierSP() + StatPointCostSum), eCleanup_Never);
		`XEVENTMGR.TriggerEvent('AbilityPointsChange', UpdatedUnit, , UpdateState);

		`GAMERULES.SubmitGameState(UpdateState);

		Movie.Pres.PlayUISound(eSUISound_SoldierPromotion);
		super.OnCancel();
	}
	else
	{
		Movie.Pres.PlayUISound(eSUISound_MenuClickNegative);
	}
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	//bsg-jneal (5.23.17): no input when not focused
	if(!bIsFocused)
	{
		return false;
	}
	//bsg-jneal (5.23.17): end

	if ( CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
	{
		switch( cmd )
		{
			case class'UIUtilities_Input'.const.FXS_BUTTON_X:
				OnAccept();
				return true;
			// Want the UIPanel_StatUI_StatLine to handle these, so need to stop
			// UIArmory::OnUnrealCommand() handling them. So super one further up the chain.
			case class'UIUtilities_Input'.const.FXS_BUTTON_A:
			case class'UIUtilities_Input'.const.FXS_KEY_ENTER:
			case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR:
				return super(UIScreen).OnUnrealCommand(cmd, arg);
		}
	}
	return super.OnUnrealCommand(cmd, arg);
}

function bool OnClickedIncrease(ECharStatType StatType, int NewStatValue, int StatCost)
{
	local bool bCanIncrease;
	local int PointsLeft, SPLeft, CostRemain;
	
	`LOG(self.Class.name @ GetFuncName() @ StatType @ NewStatValue, bLog, 'RPG');
	
	PointsLeft = GetSoldierSP() + GetSoldierAP() - AbilityPointCostSum - StatPointCostSum - StatCost;

	//`LOG(default.Class @ GetFuncName() @ "PointsLeft after buy" @ PointsLeft,, 'RPG');

	bCanIncrease = (PointsLeft >= 0);	
	if (bCanIncrease)
	{
		
		SPLeft = GetSoldierSP() - StatPointCostSum - StatCost;
		if (SPLeft >= 0)
		{
			StatPointCostSum += StatCost;
		}
		else
		{
			CostRemain = StatCost + SPLeft;
			StatPointCostSum += CostRemain;
			AbilityPointCostSum += StatCost - CostRemain;
		}
		PopulateSoldierPoints();
	}

	//`LOG(self.Class.name @ GetFuncName() @ GetSoldierAP() @ StatCost @ AbilityPointCostSum @ PointsLeft @ bCanIncrease, bLog, 'RPG');

	return bCanIncrease;
}

function bool OnClickedDecrease(ECharStatType StatType, int NewStatValue, int StatCost)
{
	local bool bCanDecrease;
	
	`LOG(self.Class.name @ GetFuncName() @ StatType @ NewStatValue @ StatCost, bLog, 'RPG');

	bCanDecrease = (NewStatValue >=  int(UnitState.GetMaxStat(StatType)));

	if (bCanDecrease)
	{
		if (StatCost <= AbilityPointCostSum)
		{
			AbilityPointCostSum -= StatCost;	
		}
		else
		{
			StatPointCostSum -= (StatCost - AbilityPointCostSum);
			AbilityPointCostSum = 0;
		}
		PopulateSoldierPoints();
	}

	return bCanDecrease;
}

//simulated static function CycleToSoldier(StateObjectReference NewRef)
//{
//	local UIScreen_StatUI StatUIScreen;
//	local UIScreenStack ScreenStack;
//
//	super.CycleToSoldier(NewRef);
//
//	ScreenStack = `SCREENSTACK;
//	StatUIScreen = UIScreen_StatUI(ScreenStack.GetScreen(class'UIScreen_StatUI'));
//
//	if(StatUIScreen != none)
//	{
//		StatUIScreen.InitPanels();
//	}
//}

simulated function bool IsAllowedToCycleSoldiers()
{
	return false;
}

// Needed a couple of tweaks from the UIArmoury version, but now heavily cut down
// since for example, we *know* IsAllowedToCycleSoldiers() will always be false
simulated function UpdateNavHelp()
{
	if(!bIsFocused)
		return; //bsg-crobinson (5.30.17): If not focused return

	NavHelp.ClearButtonHelp();
	NavHelp.AddBackButton(OnCancel);

	if( `ISCONTROLLERACTIVE )
	{
		NavHelp.AddLeftHelp(class'UIUtilities_Text'.default.m_strGenericAdjust, class'UIUtilities_Input'.const.ICON_DPAD_HORIZONTAL);
		NavHelp.AddCenterHelp( m_strRotateNavHelp, class'UIUtilities_Input'.static.GetGamepadIconPrefix() $ class'UIUtilities_Input'.const.ICON_RSTICK); // bsg-jrebar (4/26/17): Armory UI consistency changes, centering buttons, fixing overlaps, removed button inlining
	}
	// Don't allow jumping to the geoscape from the armory in the tutorial or when coming from squad select
	else if(XComHQPresentationLayer(Movie.Pres) != none && class'XComGameState_HeadquartersXCom'.static.GetObjectiveStatus('T0_M7_WelcomeToGeoscape') != eObjectiveState_InProgress &&
		RemoveMenuEvent == '' && NavigationBackEvent == '' && !`ScreenStack.IsInStack(class'UISquadSelect'))
	{
		NavHelp.AddGeoscapeButton();
	}

	NavHelp.Show();
}

defaultproperties
{
	StatOffsetY=90
	LeftPadding=40
	Padding=20
	FontSize=32
	Width=1120
	Height=750
	bLog=true
}