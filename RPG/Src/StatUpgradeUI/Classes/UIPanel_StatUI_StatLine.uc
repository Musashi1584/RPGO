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
var UIText StatName, StatValueText, UpgradeCost;
var ECharStatType StatType;
var int IconSize;
var int InitStatValue, StatValue;
var bool bLog;

var delegate<OnStatUpdateDelegate> CustomOnClickedIncreaseFn;
var delegate<OnStatUpdateDelegate> CustomOnClickedDecreaseFn;

delegate bool OnStatUpdateDelegate(ECharStatType StatType, int NewStatValue);

simulated function UIPanel InitStatLine(
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
	StatName.SetX(RunningOffsetX += 80);

	StatValueText = Spawn(class'UIText', self).InitText(name(PanelName $ "StatValue"));
	StatValueText.SetX(RunningOffsetX += 260);
	UpdateStatValue(StatValue);

	MinusSign = Spawn(class'UIButton', self).InitButton(name(PanelName $ "Minus"), "-", OnClickedDecrease);
	MinusSign.SetFontSize(48);
	MinusSign.SetResizeToText(true);
	MinusSign.SetX(RunningOffsetX += 100);

	PlusSign = Spawn(class'UIButton', self).InitButton(name(PanelName $ "Plus"), "+", OnClickedIncrease);
	PlusSign.SetFontSize(48);
	PlusSign.SetResizeToText(true);
	PlusSign.SetX(RunningOffsetX += 155);

	UpgradeCost = Spawn(class'UIText', self).InitText(name(PanelName $ "UpgradeCost"));
	UpgradeCost.SetX(RunningOffsetX += 180);
	UpdateUpgradeCost();
	

	`LOG(self.class.name @ GetFuncName() @ PanelName @ "finished", bLog, 'RPG');

	return self;
}

function UpdateUpgradeCost()
{
	UpgradeCost.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(String(GetUpgradeCost()), eUIState_Warning, 48));
}

function UpdateStatValue(int NewValue)
{
	local EUIState UIState;

	UIState = eUIState_Normal;

	if (NewValue > InitStatValue)
		UIState = eUIState_Good;

	StatValueText.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(String(NewValue), UIState, 48));
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

function int GetUpgradeCost()
{
	return (StatValue - InitStatValue) * GetStatCost();
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


function OnClickedIncrease(UIButton Button)
{
	local int NewStatValue;

	NewStatValue = StatValue + 1;

	`LOG(self.Class.name @ GetFuncName() @ StatType @ NewStatValue, bLog, 'RPG');

	if (CustomOnClickedIncreaseFn(StatType, NewStatValue))
	{
		StatValue = NewStatValue;
		UpdateStatValue(NewStatValue);
		UpdateUpgradeCost();
	}
}

function OnClickedDecrease(UIButton Button)
{
	local int NewStatValue;

	NewStatValue = StatValue - 1;

	`LOG(self.Class.name @ GetFuncName() @ StatType @ NewStatValue, bLog, 'RPG');

	if (CustomOnClickedDecreaseFn(StatType, NewStatValue))
	{
		StatValue = NewStatValue;
		UpdateStatValue(StatValue);
		UpdateUpgradeCost();
	}
}

simulated function UIPanel SetPosition(float NewX, float NewY)
{
	`LOG(self.Class.name @ GetFuncName() @ NewX @ NewY, bLog, 'RPG');
	Image.SetY(NewY);
	StatName.SetY(NewY);
	StatValueText.SetY(NewY);
	MinusSign.SetY(NewY);
	PlusSign.SetY(NewY);
	UpgradeCost.SetY(NewY);
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

defaultproperties
{
	Width=1000
	Height=80
	IconSize=64
	bLog=true
}