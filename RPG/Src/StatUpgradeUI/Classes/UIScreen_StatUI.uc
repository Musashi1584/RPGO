class UIScreen_StatUI extends UIArmory config(UI);

var UIPanel Container;
var UIBGBox PanelBG;
var UIBGBox FullBG;
var UIButton SaveButton;
var UIText AbilityPointsText, SoldierNameText;
var array<UIPanel_StatUI_StatLine> StatLines;
var bool bLog;

var XComGameState_Unit UnitState;
var int AbilityPointCostSum;

simulated function InitArmory(StateObjectReference UnitRef, optional name DispEvent, optional name SoldSpawnEvent, optional name NavBackEvent, optional name HideEvent, optional name RemoveEvent, optional bool bInstant = false, optional XComGameState InitCheckGameState)
{
	local UIPanel_StatUI_StatLine StatLine;
	local int Index, OffsetX, OffsetY, RunningHeaderOffsetX;

	super.InitArmory(UnitRef, DispEvent, SoldSpawnEvent, NavBackEvent, HideEvent, RemoveEvent, bInstant, InitCheckGameState);
	
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));

	Container = Spawn(class'UIPanel', self).InitPanel('theContainer');
	Container.Width = Width;
	Container.Height = Height;
	Container.SetPosition((Movie.UI_RES_X - Container.Width) / 2, (Movie.UI_RES_Y- Container.Height) / 2);
	
	FullBG = Spawn(class'UIBGBox', Container);
	FullBG.InitBG('', 0, 0, Container.Width, Container.Height);

	PanelBG = Spawn(class'UIBGBox', Container);
	PanelBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	PanelBG.InitBG('theBG', 0, 0, Container.Width, Container.Height);

	SoldierNameText = Spawn(class'UIText', Container).InitText('SoldierNameText');
	SoldierNameText.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(UnitState.GetFullName(), eUIState_Normal, 48));
	SoldierNameText.SetWidth(400);
	SoldierNameText.SetPosition(RunningHeaderOffsetX += 40, 40);

	AbilityPointsText = Spawn(class'UIText', Container).InitText('AbilityPointsText');
	AbilityPointsText.SetPosition(RunningHeaderOffsetX += SoldierNameText.Width, 40);

	SaveButton = Spawn(class'UIButton', Container).InitButton('SaveButton', "SAVE", Save);
	SaveButton.SetFontSize(48);
	SaveButton.SetResizeToText(true);
	SaveButton.SetWidth(150);
	SaveButton.SetPosition(Width / 2 - SaveButton.Width / 2, Height - SaveButton.Height - 50);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_HP, int(UnitState.GetMaxStat(eStat_HP)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Mobility, int(UnitState.GetMaxStat(eStat_Mobility)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Offense, int(UnitState.GetMaxStat(eStat_Offense)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Will, int(UnitState.GetMaxStat(eStat_Will)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_ArmorMitigation, int(UnitState.GetMaxStat(eStat_ArmorMitigation)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Dodge, int(UnitState.GetMaxStat(eStat_Dodge)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Defense, int(UnitState.GetMaxStat(eStat_Defense)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_Hacking, int(UnitState.GetMaxStat(eStat_Hacking)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);
	
	StatLine = Spawn(class'UIPanel_StatUI_StatLine', Container).InitStatLine(eStat_PsiOffense, int(UnitState.GetMaxStat(eStat_PsiOffense)), OnClickedIncrease, OnClickedDecrease);
	StatLines.AddItem(StatLine);

	foreach StatLines(StatLine)
	{
		OffsetX = 40;
		OffsetY = 36;
		StatLine.SetPosition(OffsetX, 80 + (OffsetY * Index));
		`LOG(self.class.name @ GetFuncName() @ StatLine.MCName @ "SetPosition", bLog, 'RPG');
		Index++;
	}

	UIIUpdateSoldierAP();

	`LOG(self.class.name @ GetFuncName() @ UnitState.GetFullName(), bLog, 'RPG');
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
	return UnitState.AbilityPoints;
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
	if (AbilityPointCostSum > 0)
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

	bCanDecrease = (NewStatValue >=  int(UnitState.GetMaxStat(StatType)));

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
	Height=900
	bLog=true
}