class UIScreen_StatUI extends UIArmory config(UI);

var UIPanel Container;
var UIBGBox PanelBG;
var UIBGBox FullBG;
var UIButton SaveButton, AbortButton;
var UIText AbilityPointsText;
var array<UIPanel_StatUI_StatLine> StatLines;
var bool bLog;

var XComGameState_Unit UnitState;
var int AbilityPointCostSum;

simulated function InitArmory(StateObjectReference UnitRef, optional name DispEvent, optional name SoldSpawnEvent, optional name NavBackEvent, optional name HideEvent, optional name RemoveEvent, optional bool bInstant = false, optional XComGameState InitCheckGameState)
{
	super.InitArmory(UnitRef, DispEvent, SoldSpawnEvent, NavBackEvent, HideEvent, RemoveEvent, bInstant, InitCheckGameState);
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
	`LOG(self.class.name @ GetFuncName() @ UnitState.GetFullName(), bLog, 'RPG');
}

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local UIPanel_StatUI_StatLine StatLine;
	local int Index, OffsetX, OffsetY;
	//local string color;

	super.InitScreen(InitController, InitMovie, InitName);

	Container = Spawn(class'UIPanel', self).InitPanel('theContainer');
	Container.Width = Width;
	Container.Height = Height;
	Container.SetPosition((Movie.UI_RES_X - Container.Width) / 2, (Movie.UI_RES_Y- Container.Height) / 2);
	
	FullBG = Spawn(class'UIBGBox', Container);
	FullBG.InitBG('', 0, 0, Container.Width, Container.Height);

	PanelBG = Spawn(class'UIBGBox', Container);
	PanelBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	PanelBG.InitBG('theBG', 0, 0, Container.Width, Container.Height);

	AbilityPointsText = Spawn(class'UIText', Container).InitText('AbilityPointsText');
	AbilityPointsText.SetPosition(40, 40);
	UIIUpdateSoldierAP();

	AbortButton = Spawn(class'UIButton', Container).InitButton('AbortButton', "CANCEL", Abort);
	AbortButton.SetFontSize(48);
	AbortButton.SetResizeToText(true);
	AbortButton.SetWidth(150);
	AbortButton.SetPosition(Width / 2 - AbortButton.Width - 10, Height - AbortButton.Height - 80);

	SaveButton = Spawn(class'UIButton', Container).InitButton('SaveButton', "SAVE", Save);
	SaveButton.SetFontSize(48);
	SaveButton.SetResizeToText(true);
	SaveButton.SetWidth(150);
	SaveButton.SetPosition(Width / 2 + 10, Height - SaveButton.Height - 80);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_HP, 10, OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Mobility, 10, OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Offense, 100, OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Will, 10, OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_ArmorMitigation, 10, OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Dodge, 10, OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Defense, 10, OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Hacking, 10, OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_PsiOffense, 10, OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);

	foreach StatLines(StatLine)
	{
		OffsetX = 40;
		OffsetY = 36;
		StatLine.SetPosition(OffsetX, 80 + (OffsetY * Index));
		`LOG(self.class.name @ GetFuncName() @ StatLine.MCName @ "SetPosition", bLog, 'RPG');
		Index++;
	}

	`LOG(self.class.name @ GetFuncName() @ "finished", bLog, 'RPG');
}

function UIPanel_StatUI_StatLine GetStatLine(ECharStatType StatType)
{
	local UIPanel_StatUI_StatLine StatLine;

	foreach StatLines(StatLine)
	{
		if (StatLine.MCName == name(string(StatType)))
		{
			`LOG(self.class.name @ GetFuncName() @ StatLine.MCName, bLog, 'RPG');
			return StatLine;
		}
	}

	return none;
}

function UIIUpdateSoldierAP()
{
	local int CurrentAP;

	CurrentAP = GetSoldierAP() - AbilityPointCostSum;

	AbilityPointsText.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(class'UIArmory_PromotionHero'.default.m_strSoldierAPLabel @ string(CurrentAP), eUIState_Normal, 48));
}

function int GetSoldierAP()
{
	return 100;
}

function Save(UIButton Button)
{
	`LOG(self.Class.name @ GetFuncName(), bLog, 'RPG');
	OnAccept();
}

function Abort(UIButton Button)
{
	`LOG(self.Class.name @ GetFuncName(), bLog, 'RPG');
	OnCancel();
}

simulated function OnCancel()
{
	super.OnCancel();
}

simulated function OnAccept()
{
	
}

function bool OnClickedIncrease(ECharStatType StatType, int NewStatValue, int StatCost)
{
	local bool bCanIncrease;
	local int AbilityPointsLeft;
	
	`LOG(self.Class.name @ GetFuncName() @ StatType @ NewStatValue, bLog, 'RPG');
	
	AbilityPointsLeft = GetSoldierAP() - AbilityPointCostSum - StatCost;
	bCanIncrease = (AbilityPointsLeft) >= 0;
	if (bCanIncrease)
	{
		AbilityPointCostSum += StatCost;
		UIIUpdateSoldierAP();
	}

	`LOG(self.Class.name @ GetFuncName() @ GetSoldierAP() @ StatCost @ AbilityPointCostSum @ AbilityPointsLeft @ bCanIncrease, bLog, 'RPG');

	return bCanIncrease;
}

function bool OnClickedDecrease(ECharStatType StatType, int NewStatValue, int StatCost)
{
	local bool bCanDecrease;
	
	`LOG(self.Class.name @ GetFuncName() @ StatType @ NewStatValue @ StatCost, bLog, 'RPG');

	bCanDecrease = (NewStatValue >= 10);

	if (bCanDecrease)
	{
		AbilityPointCostSum -= StatCost;
		UIIUpdateSoldierAP();
	}

	return bCanDecrease;
}

defaultproperties
{
	Width=1400
	Height=1000
	bLog=true
}