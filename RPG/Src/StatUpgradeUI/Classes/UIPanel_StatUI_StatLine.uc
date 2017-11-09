class UIPanel_StatUI_StatLine extends UIPanel config (UI);

struct StatCostBind
{
	var ECharStatType Stat;
	var int AbilityPointCost;
};

struct StatIconBind
{
	var ECharStatType Stat;
	var string Icon;
};

struct StatLocaleBind
{
	var ECharStatType Stat;
	var string LocalString;
};

var config array<StatIconBind> StatIcons;
var config array<StatCostBind> StatCosts;

var array<StatLocaleBind> StatLocales;

var ArtifactCost TotalCost, CurrentCost;
var UIButton MinusSign, PlusSign;
var UIImage Image;
var UIText StatName, StatValueText, UpgradeCostSum, StatCostText;
var ECharStatType StatType;
var int IconSize, Padding;
var int InitStatValue, StatValue;
var bool bLog;

var delegate<OnStatUpdateDelegate> CustomOnClickedIncreaseFn;
var delegate<OnStatUpdateDelegate> CustomOnClickedDecreaseFn;

delegate bool OnStatUpdateDelegate(ECharStatType StatType, int NewStatValue, int StatCost);

simulated function UIPanel_StatUI_StatLine InitStatLine(
	ECharStatType InitStatType,
	int InitialStatValue,
	delegate<OnStatUpdateDelegate> OnClickedIncreaseFn,
	delegate<OnStatUpdateDelegate> OnClickedDecreaseFn
)
{
	local name PanelName;
	local int RunningOffsetX;

	PanelName = name(string(InitStatType));
	InitPanel(PanelName);
	SetSize(Width, Height);

	InitStatLocales();
	StatType = InitStatType;
	StatValue = InitialStatValue;
	InitStatValue = InitialStatValue;

	CustomOnClickedIncreaseFn = OnClickedIncreaseFn;
	CustomOnClickedDecreaseFn = OnClickedDecreaseFn;

	Image = Spawn(class'UIImage', self).InitImage(name(PanelName $ '_Image'), GetStatIcon());
	Image.SetSize(IconSize, IconSize);
	Image.SetColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	Image.SetX(RunningOffsetX += 20);

	StatName = Spawn(class'UIText', self).InitText(PanelName);
	StatName.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(GetStatLocale(), eUIState_Normal, 48));
	StatName.SetX(RunningOffsetX += Image.Width + Padding);
	StatName.SetWidth(260);

	StatValueText = Spawn(class'UIText', self).InitText(name(PanelName $ "StatValue"));
	StatValueText.SetX(RunningOffsetX += StatName.Width + Padding);
	StatValueText.SetWidth(100);

	MinusSign = Spawn(class'UIButton', self).InitButton(name(PanelName $ "Minus"), "-", OnClickedDecrease);
	MinusSign.SetFontSize(48);
	MinusSign.SetResizeToText(true);
	MinusSign.SetWidth(150);
	MinusSign.SetX(RunningOffsetX += StatValueText.Width + Padding);

	PlusSign = Spawn(class'UIButton', self).InitButton(name(PanelName $ "Plus"), "+", OnClickedIncrease);
	PlusSign.SetFontSize(48);
	PlusSign.SetResizeToText(true);
	PlusSign.SetWidth(150);
	PlusSign.SetX(RunningOffsetX += MinusSign.Width + Padding);

	StatCostText = Spawn(class'UIText', self).InitText(name(PanelName $ "StatCost"));
	StatCostText.SetX(RunningOffsetX += PlusSign.Width + Padding);
	StatCostText.SetWidth(200);
	
	UpgradeCostSum = Spawn(class'UIText', self).InitText(name(PanelName $ "UpgradeCostSum"));
	UpgradeCostSum.SetX(RunningOffsetX += StatCostText.Width + Padding);
	UpgradeCostSum.SetWidth(140);

	UpdateStatValue(StatValue);
	UpdateUpgradeCostSum();
	
	`LOG(self.class.name @ GetFuncName() @ PanelName @ "finished", bLog, 'RPG');

	return self;
}

function UpdateUpgradeCostSum()
{
	local string StatCostString, UpgradeCostSumString;

	StatCostString = string(StatValue - InitStatValue) $ " * " $ GetStatCost();
	StatCostText.SetHtmlText(class'UIUtilities_Text'.static.AlignLeft(class'UIUtilities_Text'.static.GetColoredText(StatCostString, eUIState_Normal, 48)));

	UpgradeCostSumString = String(GetUpgradeCostSum()) @ "AP";
	UpgradeCostSum.SetHtmlText(class'UIUtilities_Text'.static.AlignRight(class'UIUtilities_Text'.static.GetColoredText(UpgradeCostSumString, eUIState_Normal, 48)));
}

function UpdateStatValue(int NewValue)
{
	local EUIState UIState;
	local string FormattedText;

	UIState = eUIState_Normal;

	if (NewValue > InitStatValue)
		UIState = eUIState_Good;

	FormattedText = class'UIUtilities_Text'.static.GetColoredText(String(NewValue), UIState, 48);

	StatValueText.SetHtmlText(class'UIUtilities_Text'.static.AlignRight(FormattedText));
}


function int GetUpgradeCostSum()
{
	return (StatValue - InitStatValue) * GetStatCost();
}

function OnClickedIncrease(UIButton Button)
{
	local int NewStatValue;

	NewStatValue = StatValue + 1;

	`LOG(self.Class.name @ GetFuncName() @ StatType @ NewStatValue @ GetStatCost(), bLog, 'RPG');

	if (CustomOnClickedIncreaseFn(StatType, NewStatValue, GetStatCost()))
	{
		StatValue = NewStatValue;
		UpdateStatValue(NewStatValue);
		UpdateUpgradeCostSum();
	}
}

function OnClickedDecrease(UIButton Button)
{
	local int NewStatValue;

	NewStatValue = StatValue - 1;

	`LOG(self.Class.name @ GetFuncName() @ StatType @ NewStatValue @ GetStatCost(), bLog, 'RPG');

	if (CustomOnClickedDecreaseFn(StatType, NewStatValue, GetStatCost()))
	{
		StatValue = NewStatValue;
		UpdateStatValue(StatValue);
		UpdateUpgradeCostSum();
	}
}

simulated function UIPanel SetPosition(float NewX, float NewY)
{
	`LOG(self.Class.name @ GetFuncName() @ NewX @ NewY, bLog, 'RPG');
	Image.SetY(NewY);
	StatName.SetY(NewY);
	StatValueText.SetY(NewY);
	StatCostText.SetY(NewY);
	MinusSign.SetY(NewY);
	PlusSign.SetY(NewY);
	UpgradeCostSum.SetY(NewY);
	return super.SetPosition(NewX, NewY);
}

function InitStatLocales()
{
	local StatLocaleBind StatLocale;

	StatLocale.Stat = eStat_HP;
	StatLocale.LocalString = class'XLocalizedData'.default.HealthLabel;
	StatLocales.AddItem(StatLocale);

	StatLocale.Stat = eStat_Mobility;
	StatLocale.LocalString = class'XLocalizedData'.default.MobilityLabel;
	StatLocales.AddItem(StatLocale);

	StatLocale.Stat = eStat_Offense;
	StatLocale.LocalString = class'XLocalizedData'.default.AimLabel;
	StatLocales.AddItem(StatLocale);

	StatLocale.Stat = eStat_Will;
	StatLocale.LocalString = class'XLocalizedData'.default.WillLabel;
	StatLocales.AddItem(StatLocale);

	StatLocale.Stat = eStat_ArmorMitigation;
	StatLocale.LocalString = class'XLocalizedData'.default.ArmorLabel;
	StatLocales.AddItem(StatLocale);

	StatLocale.Stat = eStat_Dodge;
	StatLocale.LocalString = class'XLocalizedData'.default.DodgeLabel;
	StatLocales.AddItem(StatLocale);

	StatLocale.Stat = eStat_Defense;
	StatLocale.LocalString = class'XLocalizedData'.default.DefenseLabel;
	StatLocales.AddItem(StatLocale);

	StatLocale.Stat = eStat_Hacking;
	StatLocale.LocalString = class'XLocalizedData'.default.TechLabel;
	StatLocales.AddItem(StatLocale);

	StatLocale.Stat = eStat_PsiOffense;
	StatLocale.LocalString = class'XLocalizedData'.default.PsiOffenseLabel;
	StatLocales.AddItem(StatLocale);
}

function int GetStatCost()
{
	local int Index;

	Index = default.StatCosts.Find('Stat', StatType);

	if (Index != INDEX_NONE)
	{
		`LOG(self.class.name @ GetFuncName() @ default.StatCosts[Index].AbilityPointCost, bLog, 'RPG');
		return default.StatCosts[Index].AbilityPointCost;
	}

	return 0;
}

function string GetStatLocale()
{
	local int Index;

	Index = StatLocales.Find('Stat', StatType);

	if (Index != INDEX_NONE)
	{
		`LOG(self.class.name @ GetFuncName() @ StatLocales[Index].LocalString, bLog, 'RPG');
		return StatLocales[Index].LocalString;
	}

	return "";
}

function string GetStatIcon()
{
	local int Index;

	Index = default.StatIcons.Find('Stat', StatType);

	if (Index != INDEX_NONE)
	{
		`LOG(self.class.name @ GetFuncName() @ default.StatIcons[Index].Icon, bLog, 'RPG');
		return default.StatIcons[Index].Icon;
	}

	return "";
}

defaultproperties
{
	Width=1400
	Height=80
	Padding=20
	IconSize=64
	bLog=false
}