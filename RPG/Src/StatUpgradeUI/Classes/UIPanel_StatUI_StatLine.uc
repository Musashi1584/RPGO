class UIPanel_StatUI_StatLine extends UIPanel config (UI);

struct StatCostBind
{
	var ECharStatType Stat;
	var int AbilityPointCost;
	var int NonLinearProgressionCostLamda;
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
var config float HealthAbilityPointCostBetaStrikeMultiplier, HealthAbilityPointCostDeltaStrikeMultiplier;
var config int HealthBetaStrikeCostLamda, HealthDeltaStrikeCostLamda;

var array<StatLocaleBind> StatLocales;

var ArtifactCost TotalCost, CurrentCost;
var UIButton MinusSign, PlusSign;
var UIImage Image;
var UIText StatName, StatValueText, UpgradeCostSum, StatCostText, UpgradePontsText;
var ECharStatType StatType;
var int IconSize, Padding, FontSize;
var int InitStatValue, StatValue;
var bool bLog;
var bool bUseBetaStrikeHealthProgression;

var delegate<OnStatUpdateDelegate> CustomOnClickedIncreaseFn;
var delegate<OnStatUpdateDelegate> CustomOnClickedDecreaseFn;

var localized string PsiOffenseLabel;

delegate bool OnStatUpdateDelegate(ECharStatType UpdateStatType, int NewStatValue, int StatCost);

simulated function UIPanel_StatUI_StatLine InitStatLine(
	ECharStatType InitStatType,
	int InitialStatValue,
	delegate<OnStatUpdateDelegate> OnClickedIncreaseFn,
	delegate<OnStatUpdateDelegate> OnClickedDecreaseFn,
	optional bool UseBetaStrikeHealthProgression = false
)
{
	local name PanelName;

	PanelName = name(string(InitStatType));
	InitPanel(PanelName);
	SetSize(Width, Height);

	InitStatLocales();
	StatType = InitStatType;
	StatValue = InitialStatValue;
	InitStatValue = InitialStatValue;
	bUseBetaStrikeHealthProgression = UseBetaStrikeHealthProgression;

	CustomOnClickedIncreaseFn = OnClickedIncreaseFn;
	CustomOnClickedDecreaseFn = OnClickedDecreaseFn;

	InitChildPanels(PanelName, 150, 80, 60, 150, 100, 120);

	UpdateStatValue(StatValue);
	UpdateUpgradeCostSum();
	
	`LOG(self.class.name @ GetFuncName() @ PanelName @ "finished", bLog, 'RPG');

	return self;
}

function InitChildPanels(
	name PanelName,
	int StatNameWidth,
	int StatValueTextWidth,
	int UpgradePontsTextWidth,
	int ButtonWidth,
	int StatCostTextWidth,
	int UpgradeCostSumWidth)
{
	local int RunningOffsetX;

	RunningOffsetX = 0;

	Image = Spawn(class'UIImage', self).InitImage(name(PanelName $ '_Image'), GetStatIcon());
	Image.SetSize(IconSize, IconSize);
	Image.SetColor(class'UIUtilities_Colors'.const.NORMAL_HTML_COLOR);
	Image.SetX(RunningOffsetX);

	StatName = Spawn(class'UIText', self).InitText(PanelName);
	StatName.SetHtmlText(class'UIUtilities_Text'.static.GetColoredText(GetStatLocale(), eUIState_Normal, FontSize));
	StatName.SetX(RunningOffsetX += Image.Width + Padding);
	StatName.SetWidth(StatNameWidth);

	StatValueText = Spawn(class'UIText', self).InitText(name(PanelName $ "StatValue"));
	StatValueText.SetX(RunningOffsetX += StatName.Width + Padding);
	StatValueText.SetWidth(StatValueTextWidth);

	UpgradePontsText = Spawn(class'UIText', self).InitText(name(PanelName $ "UpgradePonts"));
	UpgradePontsText.SetX(RunningOffsetX += StatValueText.Width + Padding);
	UpgradePontsText.SetWidth(UpgradePontsTextWidth);

	MinusSign = Spawn(class'UIButton', self).InitButton(name(PanelName $ "Minus"), "-", OnClickedDecrease);
	MinusSign.SetFontSize(FontSize);
	MinusSign.SetResizeToText(true);
	MinusSign.SetWidth(ButtonWidth);
	MinusSign.SetX(RunningOffsetX += UpgradePontsText.Width + Padding + 20);

	PlusSign = Spawn(class'UIButton', self).InitButton(name(PanelName $ "Plus"), "+", OnClickedIncrease);
	PlusSign.SetFontSize(FontSize);
	PlusSign.SetResizeToText(true);
	PlusSign.SetWidth(ButtonWidth);
	PlusSign.SetX(RunningOffsetX += MinusSign.Width + Padding);

	StatCostText = Spawn(class'UIText', self).InitText(name(PanelName $ "StatCost"));
	StatCostText.SetX(RunningOffsetX += PlusSign.Width + Padding);
	StatCostText.SetWidth(StatCostTextWidth);
	
	UpgradeCostSum = Spawn(class'UIText', self).InitText(name(PanelName $ "UpgradeCostSum"));
	UpgradeCostSum.SetX(RunningOffsetX += StatCostText.Width + Padding);
	UpgradeCostSum.SetWidth(UpgradeCostSumWidth);
}

function UpdateUpgradeCostSum()
{
	local string StatCostString, UpgradeCostSumString, UpgradePoints;

	StatCostString = string(GetStatCost(StatValue + 1)) @ "AP";
	StatCostText.SetHtmlText(class'UIUtilities_Text'.static.AlignRight(class'UIUtilities_Text'.static.GetColoredText(StatCostString, eUIState_Normal, FontSize)));

	UpgradePoints = string(StatValue - InitStatValue);
	UpgradePontsText.SetHtmlText(class'UIUtilities_Text'.static.AlignRight(class'UIUtilities_Text'.static.GetColoredText(UpgradePoints, eUIState_Normal, FontSize)));

	UpgradeCostSumString = String(GetUpgradeCostSum()) @ "AP";
	UpgradeCostSum.SetHtmlText(class'UIUtilities_Text'.static.AlignRight(class'UIUtilities_Text'.static.GetColoredText(UpgradeCostSumString, eUIState_Normal, FontSize)));
}

function UpdateStatValue(int NewValue)
{
	local EUIState UIState;
	local string FormattedText;

	UIState = eUIState_Normal;

	if (NewValue > InitStatValue)
		UIState = eUIState_Good;

	FormattedText = class'UIUtilities_Text'.static.GetColoredText(String(NewValue), UIState, FontSize);

	StatValueText.SetHtmlText(class'UIUtilities_Text'.static.AlignRight(FormattedText));
}


function int GetUpgradeCostSum()
{
	local int StatValueIncrement, Sum;

	if ((StatValue - InitStatValue) > 0)
	{
		for (StatValueIncrement = InitStatValue + 1; StatValueIncrement <= StatValue; StatValueIncrement++)
		{
			Sum += GetStatCost(StatValueIncrement);
		}
	}

	return Sum;
}

function OnClickedIncrease(UIButton Button)
{
	local int NewStatValue;

	NewStatValue = StatValue + 1;

	`LOG(self.Class.name @ GetFuncName() @ StatType @ NewStatValue @ GetStatCost(NewStatValue), bLog, 'RPG');

	if (CustomOnClickedIncreaseFn(StatType, NewStatValue, GetStatCost(NewStatValue)))
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

	`LOG(self.Class.name @ GetFuncName() @ StatType @ NewStatValue @ GetStatCost(StatValue), bLog, 'RPG');

	if (CustomOnClickedDecreaseFn(StatType, NewStatValue, GetStatCost(StatValue)))
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
	UpgradePontsText.SetY(NewY);
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
	StatLocale.LocalString = PsiOffenseLabel;
	StatLocales.AddItem(StatLocale);
}

function int GetStatCost(int NewStatValue)
{
	local int Index;
	local float Div, Cost;
	local int AbilityPointCost;

	Index = default.StatCosts.Find('Stat', StatType);

	if (Index != INDEX_NONE)
	{
		`LOG(self.class.name @ GetFuncName() @ "NewStatValue" @ NewStatValue @ "AbilityPointCost" @ default.StatCosts[Index].AbilityPointCost @ "NonLinearProgressionCostLamda" @ default.StatCosts[Index].NonLinearProgressionCostLamda, bLog, 'RPG');

		AbilityPointCost = default.StatCosts[Index].AbilityPointCost;

		if (`SecondWaveEnabled('BetaStrike') && StatType == eStat_HP && bUseBetaStrikeHealthProgression)
		{
			AbilityPointCost *= default.HealthAbilityPointCostBetaStrikeMultiplier;
			default.StatCosts[Index].NonLinearProgressionCostLamda = HealthBetaStrikeCostLamda;
			`LOG(self.class.name @ GetFuncName() @ "modifying HP because SWO BetaStrike is enabled. New AbilityPointCost" @ AbilityPointCost, bLog, 'RPG');
		}

		if (`SecondWaveEnabled('DeltaStrike') && StatType == eStat_HP && bUseBetaStrikeHealthProgression)
		{
			AbilityPointCost *= default.HealthAbilityPointCostDeltaStrikeMultiplier;
			default.StatCosts[Index].NonLinearProgressionCostLamda = HealthDeltaStrikeCostLamda;
			`LOG(self.class.name @ GetFuncName() @ "modifying HP because SWO DeltaStrike is enabled. New AbilityPointCost" @ AbilityPointCost, bLog, 'RPG');
		}

		if (default.StatCosts[Index].NonLinearProgressionCostLamda > 0)
		{
			Div = float(NewStatValue) / float(default.StatCosts[Index].NonLinearProgressionCostLamda);
			Cost = FMin(Exp(Pow(Div, 6)) * AbilityPointCost, 50.0f);
			`LOG(self.class.name @ GetFuncName() @ "Cost" @ Cost, bLog, 'RPG');
			return int(Cost + 0.5f);
		}

		return AbilityPointCost;
	}

	return 0;
}

function float Pow(Float fBase, int Exponent)
{
	local int i;
	local float Result;

	Result = fBase;
	for(i=1; i <= Exponent; i++)
	{
		Result *= fBase;
	}
	return Result;
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
	IconSize=32
	FontSize=32
	bLog=true
}